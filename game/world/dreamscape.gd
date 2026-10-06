extends Node3D
## Travel keeps the production street, player, camera, sprite and pixel pass alive.

const LourizanHistory = preload("res://dialogue/lourizan_history.gd")
const LOCATION_PATHS := {
	&"home": "res://world/locations/home.tscn",
	&"lourizan": "res://world/locations/lourizan.tscn",
}
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
var location_paths := LOCATION_PATHS.duplicate()
var current_id: StringName = &"street"
var active_location: Node3D
var near_exit: Area3D
var busy := false
var street_environment: Environment
var active_guide: Node3D
var dialogue_controls_owned := false

@onready var street: Node3D = $Street
@onready var player: CharacterBody3D = $Street/Player
@onready var camera_rig: Node3D = $Street/CameraRig
@onready var slot: Node3D = $LocationSlot
@onready var item_world: Node3D = $ItemWorld
@onready var map_ui: CanvasLayer = $TravelMap
@onready var touch_controls: Control = $Street/TouchHUD/TouchControls
@onready var item_loop: Node = $Street/ItemLoop
@onready var dialogue: CanvasLayer = $DialogueBubble
@onready var bag_ui: CanvasLayer = $BagUI


func _ready() -> void:
	street_environment = street.get_node("Environment").environment
	map_ui.open_requested.connect(open_map)
	map_ui.cancel_requested.connect(close_map)
	map_ui.destination_confirmed.connect(travel_to)
	touch_controls.map_requested.connect(open_map)
	touch_controls.talk_requested.connect(open_dialogue)
	touch_controls.bag_requested.connect(open_bag)
	item_loop.bag_requested.connect(open_bag)
	item_loop.feedback_requested.connect(bag_ui.show_feedback)
	dialogue.closed.connect(on_dialogue_closed)
	bag_ui.open_requested.connect(open_bag)
	bag_ui.close_requested.connect(close_bag)
	bag_ui.slot_selected.connect(on_bag_slot_selected)
	bag_ui.bind_inventory(item_loop.inventory)
	player.respawned.connect(close_dialogue)
	player.respawned.connect(close_bag)
	watch_exit(street)
	call_deferred("bind_initial_item_context")


func bind_initial_item_context() -> void:
	await get_tree().physics_frame
	item_loop.bind_initial_context(&"street", item_world, item_supports(street))


func item_supports(location: Node3D) -> Array[CollisionObject3D]:
	var supports: Array[CollisionObject3D] = []
	if location == street:
		supports.append(street.get_node("StreetCollision"))
		return supports
	var guide := location.get_node_or_null("LucasMaconheiro")
	for node in location.find_children("*", "StaticBody3D", true, false):
		if is_instance_valid(guide) and guide.is_ancestor_of(node):
			continue
		if node.collision_layer & 1:
			supports.append(node)
	return supports


func _process(_delta: float) -> void:
	var can_talk: bool = (
		is_instance_valid(active_guide)
		and not dialogue.is_open
		and not map_ui.is_open
		and not bag_ui.is_open
		and not busy
		and not item_loop.placement_active
		and active_guide.can_talk(player)
	)
	if is_instance_valid(active_guide):
		active_guide.set_prompt_visible(can_talk)
	touch_controls.talk_available = can_talk
	if map_ui.is_open or dialogue.is_open or bag_ui.is_open:
		return
	var location: Node3D = street if current_id == &"street" else active_location
	if location == null:
		return
	var exit: Area3D = location.get_node("Exit")
	var camera: Camera3D = camera_rig.get_node("Camera")
	var screen_direction := (
		camera.unproject_position(exit.global_position)
		- camera.unproject_position(player.global_position)
	)
	var direction_index := wrapi(roundi(screen_direction.angle() / (PI / 4.0)), 0, 8)
	var offset := exit.global_position - player.global_position
	var distance := roundi(Vector2(offset.x, offset.z).length())
	map_ui.set_guide(
		(
			"Salida al mapa · %d m\nSigue %s; pulsa M al llegar."
			% [distance, MAP_DIRECTIONS[direction_index]]
		)
	)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if dialogue.is_open:
			return
		if bag_ui.is_open:
			if event.physical_keycode in [KEY_ESCAPE, KEY_B, KEY_P]:
				close_bag()
				get_viewport().set_input_as_handled()
			return
		if event.physical_keycode in [KEY_B, KEY_P]:
			open_bag()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_E and can_open_dialogue():
			open_dialogue()
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_ESCAPE and map_ui.is_open and not busy:
			close_map()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("open_travel_map"):
			if map_ui.is_open and not busy:
				close_map()
			else:
				open_map()
			get_viewport().set_input_as_handled()


func watch_exit(location: Node3D) -> void:
	var exit: Area3D = location.get_node("Exit")
	if not exit.body_entered.is_connected(on_exit_entered):
		exit.body_entered.connect(on_exit_entered)
	if not exit.body_exited.is_connected(on_exit_left):
		exit.body_exited.connect(on_exit_left)
	near_exit = null
	map_ui.show_prompt(false)
	touch_controls.travel_available = false


func on_exit_entered(body: Node3D) -> void:
	if body == player:
		near_exit = (street if current_id == &"street" else active_location).get_node("Exit")
		map_ui.show_prompt(true)
		touch_controls.travel_available = true


func on_exit_left(body: Node3D) -> void:
	if body == player:
		near_exit = null
		map_ui.show_prompt(false)
		touch_controls.travel_available = false


func open_map() -> void:
	if (
		busy
		or dialogue.is_open
		or bag_ui.is_open
		or near_exit == null
		or not is_instance_valid(near_exit)
		or map_ui.is_open
	):
		return
	if item_loop.placement_active:
		item_loop.cancel_placement()
	player.set_input_locked(true)
	item_loop.process_mode = Node.PROCESS_MODE_DISABLED
	touch_controls.input_enabled = false
	touch_controls.reset_touch()
	map_ui.open_map(current_id)


func close_map() -> void:
	if busy or not map_ui.is_open:
		return
	map_ui.close_map()
	player.set_input_locked(false)
	item_loop.process_mode = Node.PROCESS_MODE_INHERIT
	touch_controls.input_enabled = true
	map_ui.show_prompt(near_exit != null and is_instance_valid(near_exit))


func can_open_dialogue() -> bool:
	return (
		not busy
		and not map_ui.is_open
		and not bag_ui.is_open
		and not dialogue.is_open
		and not item_loop.placement_active
		and is_instance_valid(active_guide)
		and active_guide.can_talk(player)
	)


func open_dialogue() -> void:
	if not can_open_dialogue():
		return
	dialogue_controls_owned = true
	player.set_input_locked(true)
	item_loop.process_mode = Node.PROCESS_MODE_DISABLED
	item_loop.commands.clear()
	touch_controls.input_enabled = false
	touch_controls.reset_touch()
	map_ui.guide.hide()
	map_ui.prompt.hide()
	active_guide.set_prompt_visible(false)
	active_guide.set_conversation_active(true)
	dialogue.open(
		LourizanHistory.SPEAKER, active_guide.get_node("Head"), LourizanHistory.PARAGRAPHS
	)


func close_dialogue() -> void:
	if dialogue.is_open:
		dialogue.close()


func on_dialogue_closed() -> void:
	if not dialogue_controls_owned:
		return
	dialogue_controls_owned = false
	if is_instance_valid(active_guide):
		active_guide.set_conversation_active(false)
	player.set_input_locked(false)
	item_loop.process_mode = Node.PROCESS_MODE_INHERIT
	touch_controls.input_enabled = true
	touch_controls.reset_touch()
	map_ui.show_prompt(near_exit != null and is_instance_valid(near_exit))


func bind_active_guide() -> void:
	if is_instance_valid(active_guide):
		active_guide.set_prompt_visible(false)
	active_guide = null
	if current_id == &"lourizan" and is_instance_valid(active_location):
		active_guide = active_location.get_node_or_null("LucasMaconheiro")
		if is_instance_valid(active_guide):
			active_guide.set_movement_view(camera_rig.get_node("Camera"))
	touch_controls.talk_available = false
	touch_controls.update_actions()


func open_bag() -> void:
	if busy or map_ui.is_open or dialogue.is_open or bag_ui.is_open:
		return
	if item_loop.placement_active:
		item_loop.cancel_placement()
	player.set_input_locked(true)
	item_loop.process_mode = Node.PROCESS_MODE_DISABLED
	item_loop.commands.clear()
	touch_controls.input_enabled = false
	touch_controls.reset_touch()
	map_ui.guide.hide()
	map_ui.prompt.hide()
	bag_ui.open_bag()


func close_bag() -> void:
	if not bag_ui.is_open:
		return
	bag_ui.close_bag()
	player.set_input_locked(false)
	item_loop.process_mode = Node.PROCESS_MODE_INHERIT
	touch_controls.input_enabled = true
	touch_controls.reset_touch()
	map_ui.show_prompt(near_exit != null and is_instance_valid(near_exit))


func on_bag_slot_selected(index: int) -> void:
	if not bag_ui.is_open:
		return
	close_bag()
	item_loop.begin_placement(index)


func set_street_active(active: bool) -> void:
	for name in ["StreetVisual", "Walkway", "GarageFacade", "GarageDoor", "PixelDecor"]:
		street.get_node(name).visible = active and name != "StreetVisual"
	street.get_node("StreetCollision").collision_layer = 1 if active else 0
	street.get_node("Exit").monitoring = active
	street.get_node("Environment").environment = street_environment if active else null
	street.get_node("Light").visible = active
	street.get_node("HUD").visible = active and not touch_controls.enabled
	item_loop.process_mode = Node.PROCESS_MODE_INHERIT
	item_loop.get_node("HUD").visible = not touch_controls.enabled
	if item_loop.preview != null:
		item_loop.preview.visible = item_loop.placement_active
	touch_controls.travel_only = false
	touch_controls.update_actions()


func travel_to(destination: StringName) -> bool:
	if busy or not map_ui.is_open or near_exit == null or destination == current_id:
		return false
	if destination != &"street" and not location_paths.has(destination):
		return false
	busy = true
	map_ui.set_loading()
	await get_tree().process_frame
	var incoming: Node3D
	if destination != &"street":
		incoming = load_destination(location_paths[destination])
		if incoming == null:
			return travel_failed("No se pudo cargar el destino o su entrada")
	set_street_active(destination == &"street")
	if active_location != null:
		active_location.get_node("Exit").monitoring = false
		active_location.visible = false
		active_location.process_mode = Node.PROCESS_MODE_DISABLED
	if incoming != null:
		slot.add_child(incoming)
	await get_tree().physics_frame
	var arrival: Marker3D = (
		street.get_node("Arrival") if destination == &"street" else incoming.get_node("Arrival")
	)
	var ray := PhysicsRayQueryParameters3D.create(
		arrival.global_position + Vector3.UP * 2, arrival.global_position - Vector3.UP * 3, 1
	)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray)
	if (
		hit.is_empty()
		or hit.normal.y < 0.6
		or absf(hit.position.y - arrival.global_position.y) > 1.2
	):
		if incoming != null:
			incoming.queue_free()
		if active_location != null:
			active_location.visible = true
			active_location.process_mode = Node.PROCESS_MODE_INHERIT
			active_location.get_node("Exit").monitoring = true
		set_street_active(current_id == &"street")
		return travel_failed("No hay suelo seguro en la entrada")
	if active_location != null:
		active_location.queue_free()
	item_loop.commit_location_change(
		destination, item_world, item_supports(street if destination == &"street" else incoming)
	)
	active_location = incoming
	current_id = destination
	bind_active_guide()
	if destination == &"street":
		set_street_active(true)
	player.global_position = hit.position + Vector3.UP * 0.05
	player.spawn_transform = player.global_transform
	player.velocity = Vector3.ZERO
	player.prevent_ledge_fall = destination != &"street"
	player.step_height = 0.25 if destination != &"street" else 0.0
	player.reset_physics_interpolation()
	camera_rig.base_orthographic_size = 13.5
	camera_rig.focus_height = 0.9
	camera_rig.avoid_world_geometry = true
	camera_rig.snap_to_target()
	watch_exit(street if destination == &"street" else incoming)
	map_ui.close_map()
	player.set_input_locked(false)
	touch_controls.input_enabled = true
	busy = false
	return true


func load_destination(path: String) -> Node3D:
	if not ResourceLoader.exists(path, "PackedScene"):
		return null
	var packed: PackedScene = load(path)
	if packed == null:
		return null
	var location: Node3D = packed.instantiate()
	if location == null or not location.has_node("Arrival") or not location.has_node("Exit"):
		if location != null:
			location.queue_free()
		return null
	return location


func travel_failed(message: String) -> bool:
	map_ui.show_error(message)
	busy = false
	return false
