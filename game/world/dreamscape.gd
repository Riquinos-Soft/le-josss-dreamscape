extends Node3D
## Travel keeps the production street, player, camera, sprite and pixel pass alive.

const LOCATION_PATHS := {
	&"home": "res://world/locations/home.tscn",
	&"lourizan": "res://world/locations/lourizan.tscn",
}
var location_paths := LOCATION_PATHS.duplicate()
var current_id: StringName = &"street"
var active_location: Node3D
var near_exit: Area3D
var busy := false
var street_environment: Environment
var item_collision_layer: int

@onready var street: Node3D = $Street
@onready var player: CharacterBody3D = $Street/Player
@onready var camera_rig: Node3D = $Street/CameraRig
@onready var slot: Node3D = $LocationSlot
@onready var map_ui: CanvasLayer = $TravelMap
@onready var touch_controls: Control = $Street/TouchHUD/TouchControls
@onready var item_loop: Node = $Street/ItemLoop


func _ready() -> void:
	street_environment = street.get_node("Environment").environment
	item_collision_layer = item_loop.world_item.collision_layer
	map_ui.open_requested.connect(open_map)
	map_ui.cancel_requested.connect(close_map)
	map_ui.destination_confirmed.connect(travel_to)
	touch_controls.map_requested.connect(open_map)
	watch_exit(street)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE and map_ui.is_open and not busy:
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
	if busy or near_exit == null or not is_instance_valid(near_exit) or map_ui.is_open:
		return
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
	if current_id == &"street":
		item_loop.process_mode = Node.PROCESS_MODE_INHERIT
	touch_controls.input_enabled = true
	map_ui.show_prompt(near_exit != null and is_instance_valid(near_exit))


func set_street_active(active: bool) -> void:
	for name in ["StreetVisual", "Walkway", "GarageFacade", "GarageDoor", "PixelDecor"]:
		street.get_node(name).visible = active and name != "StreetVisual"
	street.get_node("StreetCollision").collision_layer = 1 if active else 0
	street.get_node("Exit").monitoring = active
	street.get_node("Environment").environment = street_environment if active else null
	street.get_node("Light").visible = active
	street.get_node("HUD").visible = active and not touch_controls.enabled
	item_loop.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	item_loop.get_node("HUD").visible = active and not touch_controls.enabled
	item_loop.world_item.visible = active
	item_loop.world_item.collision_layer = item_collision_layer if active else 0
	if item_loop.preview != null:
		item_loop.preview.visible = active and item_loop.placement_active
	touch_controls.travel_only = not active
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
	active_location = incoming
	current_id = destination
	if destination == &"street":
		set_street_active(true)
	player.global_position = hit.position + Vector3.UP * 0.05
	player.spawn_transform = player.global_transform
	player.velocity = Vector3.ZERO
	player.prevent_ledge_fall = destination != &"street"
	player.step_height = 0.25 if destination != &"street" else 0.0
	player.reset_physics_interpolation()
	camera_rig.avoid_world_geometry = destination == &"home"
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
