extends Node3D
## Reuse authored locations, NPCs, dialogue and marked exits in the account session.

const Destinations = preload("res://v2/locations/destinations.gd")
const Direction = preload("res://player/directional_animation.gd")
const ScreenUnits = preload("res://ui/screen_units.gd")
const MAP_DIRECTIONS := [
	"derecha",
	"abajo a la derecha",
	"abajo",
	"abajo a la izquierda",
	"izquierda",
	"arriba a la izquierda",
	"arriba",
	"arriba a la derecha"
]
var session: Node3D
var location: Node3D
var map_ui: CanvasLayer
var dialogue: CanvasLayer
var map_button: Button
var talk_button: Button
var feedback: Label
var nearest := ""
var talking := ""
var pending := false
var controls_locked := true
var npc_targets := {}
var actions: VBoxContainer


func _ready() -> void:
	map_ui = preload("res://world/travel/travel_map.tscn").instantiate()
	add_child(map_ui)
	map_ui.open_requested.connect(open_map)
	map_ui.cancel_requested.connect(close_map)
	map_ui.destination_confirmed.connect(request_travel)
	dialogue = preload("res://dialogue/dialogue_bubble.tscn").instantiate()
	add_child(dialogue)
	dialogue.closed.connect(close_conversation)
	var layer := CanvasLayer.new()
	add_child(layer)
	actions = VBoxContainer.new()
	actions.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	actions.position = Vector2(-270, -150)
	actions.size = Vector2(250, 130)
	layer.add_child(actions)
	feedback = Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	actions.add_child(feedback)
	map_button = Button.new()
	map_button.text = "M · Abrir mapa"
	map_button.custom_minimum_size.y = 48
	map_button.pressed.connect(open_map)
	actions.add_child(map_button)
	talk_button = Button.new()
	talk_button.custom_minimum_size.y = 48
	talk_button.pressed.connect(request_talk)
	actions.add_child(talk_button)
	get_viewport().size_changed.connect(_fit_actions)
	_fit_actions()
	load_place("lourizan")


func load_place(place: String) -> void:
	if not Destinations.PATHS.has(place):
		session.connection_error("place_unavailable")
		return
	if location != null and String(session.current_id) == place:
		return
	close_map()
	if dialogue.is_open:
		dialogue.close()
	if location != null:
		remove_child(location)
		location.queue_free()
	npc_targets.clear()
	nearest = ""
	location = Destinations.create(place, session.actor)
	var environment := location.get_node_or_null("Environment") as WorldEnvironment
	if environment != null:
		session.get_node("AccountEnvironment").environment = environment.environment
		environment.free()
	for child in ["Sun", "Light"]:
		var light := location.get_node_or_null(child)
		if light != null:
			light.free()
	add_child(location)
	session.current_id = StringName(place)
	for path in Destinations.SPEAKERS[place]:
		var npc: Node3D = location.get_node(path)
		npc.set_physics_process(false)
		npc.set_movement_view(session.camera)
		if npc.smoking != null:
			npc.smoking.set_smoking(true)
	pending = false


func _process(delta: float) -> void:
	if location == null:
		return
	session.inside_salon = session.current_id == &"lourizan" and session.actor.position.x < -70
	for path in npc_targets:
		var npc: Node3D = location.get_node(path)
		var state: Dictionary = npc_targets[path]
		var old := npc.global_position
		npc.global_position = npc.global_position.lerp(
			location.to_global(state.position), minf(15 * delta, 1)
		)
		if state.walking:
			npc.facing = Direction.resolve_facing(
				npc.global_position - old,
				session.camera,
				npc.facing,
				String(npc.sprite.animation).begins_with("walk_")
			)
		Direction.play_direction(npc.sprite, npc.facing, state.walking)
		if npc.smoking != null:
			npc.smoking.set_smoking(not state.walking and talking != path)
	nearest = ""
	var distance := INF
	for path in Destinations.SPEAKERS[String(session.current_id)]:
		var npc: Node3D = location.get_node(path)
		var candidate: float = session.actor.global_position.distance_squared_to(
			npc.global_position
		)
		if session.admitted and candidate < distance and npc.can_talk(session.actor):
			nearest = path
			distance = candidate
	for path in Destinations.SPEAKERS[String(session.current_id)]:
		npc_prompt(location.get_node(path), path)
	refresh_controls()
	var show_actions: bool = (
		session.admitted and not map_ui.is_open and not dialogue.is_open and not pending
	)
	feedback.visible = show_actions and feedback.text != ""
	map_button.visible = show_actions and at_exit()
	talk_button.visible = show_actions and nearest != ""
	if nearest != "":
		talk_button.text = "E · Hablar"
		talk_button.tooltip_text = location.get_node(nearest).speaker_name
	map_ui.show_prompt(show_actions and at_exit())
	map_ui.prompt.hide()
	if not session.admitted or map_ui.is_open or dialogue.is_open or pending:
		map_ui.guide.hide()
		map_ui.prompt.hide()
		return
	var exit: Node3D = location.get_node("Salon/Exit" if session.inside_salon else "Exit")
	var screen_offset: Vector2 = (
		session.camera.unproject_position(exit.global_position)
		- session.camera.unproject_position(session.actor.global_position)
	)
	var index := wrapi(roundi(screen_offset.angle() / (PI / 4)), 0, 8)
	var metres: int = roundi(
		(
			Vector2(
				exit.global_position.x - session.actor.global_position.x,
				exit.global_position.z - session.actor.global_position.z
			)
			. length()
		)
	)
	map_ui.set_guide(
		(
			("Jardín" if session.inside_salon else "Salida al mapa")
			+ " · %d m\nSigue %s" % [metres, MAP_DIRECTIONS[index]]
		)
	)


func npc_prompt(npc: Node3D, path: String) -> void:
	npc.set_prompt_visible(session.admitted and nearest == path and not controls_locked)


func at_exit() -> bool:
	return location != null and location.get_node("Exit").overlaps_body(session.actor)


func refresh_controls() -> void:
	var locked: bool = not session.admitted or map_ui.is_open or dialogue.is_open or pending
	if locked == controls_locked:
		return
	controls_locked = locked
	session.input_adapter.clear_input()
	session.input_adapter.set_physics_process(not locked)
	session.input_adapter.set_process_input(not locked)


func reset_interactions() -> void:
	pending = false
	map_ui.close_map()
	if dialogue.is_open:
		dialogue.close()
	talking = ""
	feedback.text = ""
	refresh_controls()


func open_map() -> void:
	if not session.admitted or dialogue.is_open or pending or not at_exit():
		return
	map_ui.open_map(session.current_id)
	refresh_controls()


func close_map() -> void:
	if map_ui != null and map_ui.is_open and not pending:
		map_ui.close_map()
		refresh_controls()


func request_travel(destination: StringName) -> void:
	if pending or not map_ui.is_open or not Destinations.PATHS.has(String(destination)):
		return
	pending = true
	map_ui.set_loading()
	refresh_controls()
	session.send({"type": "travel", "destination": String(destination)})


func request_talk() -> void:
	if controls_locked or nearest == "":
		return
	feedback.text = ""
	pending = true
	refresh_controls()
	session.send({"type": "talk", "speaker": nearest})


func close_conversation() -> void:
	talking = ""
	session.send({"type": "talk_end"})
	refresh_controls()


func handle(message: Dictionary) -> void:
	match message.type:
		"snapshot":
			if message.get("place", "") != String(session.current_id):
				return
			for path in message.get("npcs", {}):
				if path in Destinations.SPEAKERS[String(session.current_id)]:
					var state: Dictionary = message.npcs[path]
					npc_targets[path] = {
						"position": session.to_vector(state.position), "walking": state.walking
					}
		"travelled":
			load_place(message.place)
			pending = false
			map_ui.close_map()
			refresh_controls()
		"travel_error":
			pending = false
			map_ui.show_error("Acércate a la salida o vuelve a intentarlo.")
			refresh_controls()
		"talked":
			pending = false
			feedback.text = ""
			talking = message.speaker
			var npc: Node3D = location.get_node(talking)
			var pages: Array[String] = []
			pages.assign(message.pages)
			dialogue.open(npc.speaker_name, npc.get_node("Head"), pages)
			refresh_controls()
		"talk_error":
			pending = false
			feedback.text = "Acércate un poco más para hablar."
			refresh_controls()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.physical_keycode == KEY_M:
		if map_ui.is_open:
			close_map()
		else:
			open_map()
	elif event.physical_keycode == KEY_E:
		request_talk()
	elif event.physical_keycode == KEY_ESCAPE:
		if dialogue.is_open:
			dialogue.close()
		else:
			close_map()


func _fit_actions() -> void:
	var unit := ScreenUnits.factor(get_viewport())
	var theme := Theme.new()
	theme.default_font_size = roundi(16 * unit)
	actions.theme = theme
	actions.offset_left = -270 * unit
	actions.offset_right = -20 * unit
	actions.offset_top = -150 * unit
	actions.offset_bottom = -20 * unit
	map_button.custom_minimum_size.y = 48 * unit
	talk_button.custom_minimum_size.y = 48 * unit
