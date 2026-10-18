extends Node3D
## Account entry is same-origin HTML; this scene holds only an ephemeral game ticket.

const Actor = preload("res://v2/characters/actor.gd")
const LocalInput = preload("res://v2/characters/local_input.gd")
const Catalog = preload("res://v2/characters/appearance_catalog.gd")
const Presenter = preload("res://v2/characters/appearance_presenter.gd")
const DirectionalAnimation = preload("res://player/directional_animation.gd")
var socket := WebSocketPeer.new()
var actor: CharacterBody3D
var input_adapter: Control
var camera: Camera3D
var camera_rig: Node3D
var current_id: StringName = &"lourizan"
var inside_salon := false
var presenter: AnimatedSprite3D
var catalog := Catalog.new()
var ticket := ""
var admitted := false
var hello_sent := false
var leaving := false
var sequence := 0
var elapsed := 0.0
var target_position := Vector3.ZERO
var facing: StringName = &"down"
var last_packet := 0
var connection_started := false
var world_view: Node3D


func _ready() -> void:
	var environment := WorldEnvironment.new()
	environment.name = "AccountEnvironment"
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color(0.12, 0.16, 0.19)
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color(0.82, 0.86, 0.92)
	environment.environment.ambient_light_energy = 0.65
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -30, 0)
	sun.light_energy = 0.7
	add_child(sun)
	actor = Actor.new()
	add_child(actor)
	camera_rig = preload("res://player/camera_rig.tscn").instantiate()
	camera_rig.target = actor
	camera_rig.avoid_world_geometry = true
	camera = camera_rig.get_node("Camera")
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.5
	add_child(camera_rig)
	var backdrop := preload("res://world/dream_castles.gd").new()
	backdrop.name = "DreamCastles"
	add_child(backdrop)
	var pixel_pass := CanvasLayer.new()
	pixel_pass.name = "PixelPass"
	pixel_pass.layer = -1
	add_child(pixel_pass)
	var screen := ColorRect.new()
	screen.name = "Screen"
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var grade := ShaderMaterial.new()
	grade.shader = preload("res://world/street_pixel.gdshader")
	screen.material = grade
	pixel_pass.add_child(screen)
	var daylight := preload("res://world/daylight.gd").new()
	daylight.name = "Daylight"
	daylight.screen_path = NodePath("PixelPass/Screen")
	add_child(daylight)
	actor.set_physics_process(false)
	actor.visible = false
	var hud := CanvasLayer.new()
	add_child(hud)
	input_adapter = LocalInput.new()
	input_adapter.actor = actor
	input_adapter.camera = camera
	hud.add_child(input_adapter)
	input_adapter.set_physics_process(false)
	input_adapter.set_process_input(false)
	world_view = preload("res://v2/account/world_view.gd").new()
	world_view.name = "WorldView"
	world_view.session = self
	add_child(world_view)
	if OS.has_feature("web"):
		(
			JavaScriptBridge
			. eval(
				"""
			window.accountMessages = [];
			window.addEventListener('message', event => {
			if (event.origin === location.origin && event.source === parent &&
			event.data && event.data.channel === 'dreamscape-account') {
			window.accountMessages.push(event.data);
			}
			});
			""",
				true
			)
		)
		notify_parent({"type": "ready"})


func _process(delta: float) -> void:
	poll_parent()
	if not connection_started:
		return
	socket.poll()
	var state := socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if not hello_sent:
			send({"type": "hello", "ticket": ticket})
			ticket = ""
			hello_sent = true
		while socket.get_available_packet_count() > 0:
			var value: Variant = JSON.parse_string(socket.get_packet().get_string_from_utf8())
			if value is Dictionary:
				last_packet = Time.get_ticks_msec()
				handle_packet(value)
		elapsed += delta
		if admitted and not leaving and elapsed >= 0.05:
			elapsed = 0.0
			sequence += 1
			var intent: Vector3 = actor.movement_intent
			send({"type": "move", "sequence": sequence, "intent": [intent.x, intent.z]})
		if Time.get_ticks_msec() - last_packet > 10000:
			connection_error("connection_lost")
	elif state == WebSocketPeer.STATE_CLOSED:
		connection_error("connection_lost")
	if admitted:
		var old := actor.position
		actor.position = actor.position.lerp(target_position, minf(delta * 15.0, 1.0))
		var movement := (actor.position - old) / maxf(delta, 0.001)
		movement.y = 0
		var was_walking := String(presenter.animation).begins_with("walk_")
		var walking := movement.length() > (0.06 if was_walking else 0.12)
		if walking:
			facing = DirectionalAnimation.resolve_facing(movement, camera, facing, was_walking)
		DirectionalAnimation.play_direction(presenter, facing, walking)


func poll_parent() -> void:
	if not OS.has_feature("web"):
		return
	var encoded: String = JavaScriptBridge.eval(
		"JSON.stringify(window.accountMessages.splice(0))", true
	)
	var messages: Array = JSON.parse_string(encoded)
	for message in messages:
		if message.get("type") == "connect":
			connect_game(message.socket_url, message.ticket)
		elif message.get("type") == "leave" and admitted:
			leaving = true
			input_adapter.clear_input()
			input_adapter.set_physics_process(false)
			input_adapter.set_process_input(false)
			send({"type": "leave"})


func connect_game(url: String, game_ticket: String) -> void:
	if connection_started:
		socket.close()
	socket = WebSocketPeer.new()
	ticket = game_ticket
	admitted = false
	hello_sent = false
	leaving = false
	sequence = 0
	last_packet = Time.get_ticks_msec()
	connection_started = true
	if socket.connect_to_url(url) != OK:
		connection_error("connection_lost")


func handle_packet(message: Dictionary) -> void:
	match message.get("type", ""):
		"welcome":
			var character: Dictionary = message.character
			var config: Dictionary = character.appearance
			config.version = int(config.version)
			world_view.load_place(character.get("place", "lourizan"))
			world_view.reset_interactions()
			if presenter == null:
				presenter = Presenter.new()
				presenter.catalog = catalog
				presenter.movement_actor = actor
				presenter.movement_view = camera
				presenter.pixel_size = 0.0375
				presenter.position.y = 1.05
				presenter.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
				presenter.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				presenter.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
				var error: String = presenter.apply_appearance(config)
				if error != "":
					connection_error("appearance_unavailable")
					return
				actor.add_child(presenter)
				presenter.set_physics_process(false)
			else:
				presenter.apply_appearance(config)
			target_position = to_vector(character.position)
			actor.position = target_position
			camera_rig.snap_to_target()
			actor.visible = true
			admitted = true
			world_view.refresh_controls()
			notify_parent({"type": "joined", "saved_at": character.saved_at})
		"snapshot":
			if admitted:
				target_position = to_vector(message.position)
				world_view.handle(message)
		"travelled":
			world_view.handle(message)
			target_position = to_vector(message.position)
			actor.position = target_position
			actor.reset_physics_interpolation()
			camera_rig.snap_to_target()
		"travel_error", "talked", "talk_error":
			world_view.handle(message)
		"saved":
			notify_parent(message)
		"left":
			socket.close(1000, "saved")
			connection_started = false
			admitted = false
			notify_parent(message)
		"error":
			connection_error(message.error)


func connection_error(reason: String) -> void:
	connection_started = false
	admitted = false
	world_view.reset_interactions()
	input_adapter.clear_input()
	input_adapter.set_physics_process(false)
	input_adapter.set_process_input(false)
	if presenter != null:
		DirectionalAnimation.play_direction(presenter, facing, false)
	socket.close()
	notify_parent({"type": "error", "error": reason})


func send(data: Dictionary) -> void:
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	data["version"] = 1
	socket.send_text(JSON.stringify(data))


func notify_parent(data: Dictionary) -> void:
	if OS.has_feature("web"):
		data["channel"] = "dreamscape-account"
		JavaScriptBridge.eval(
			"parent.postMessage(" + JSON.stringify(data) + ", location.origin)", true
		)


func to_vector(value: Array) -> Vector3:
	return Vector3(value[0], value[1], value[2])
