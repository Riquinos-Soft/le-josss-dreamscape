extends Node3D
## Keeps one player/camera while replacing the active real location.

const LOCATION_PATHS := {
	&"home": "res://world/locations/home.tscn",
	&"lourizan": "res://world/locations/lourizan.tscn",
}
var location_paths := LOCATION_PATHS.duplicate()
var current_id: StringName = &"home"
var active_location: Node3D
var near_exit: Area3D
var busy := false

@onready var player: CharacterBody3D = $Player
@onready var camera_rig: Node3D = $CameraRig
@onready var slot: Node3D = $LocationSlot
@onready var map_ui: CanvasLayer = $TravelMap


func _ready() -> void:
	map_ui.open_requested.connect(open_map)
	map_ui.cancel_requested.connect(close_map)
	map_ui.destination_confirmed.connect(travel_to)
	var packed: PackedScene = load(location_paths[current_id])
	active_location = packed.instantiate()
	slot.add_child(active_location)
	player.global_position = active_location.get_node("Arrival").global_position
	camera_rig.snap_to_target()
	watch_exit(active_location)


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
	exit.body_entered.connect(on_exit_entered)
	exit.body_exited.connect(on_exit_left)
	near_exit = null
	map_ui.show_prompt(false)


func on_exit_entered(body: Node3D) -> void:
	if body == player:
		near_exit = active_location.get_node("Exit")
		map_ui.show_prompt(true)


func on_exit_left(body: Node3D) -> void:
	if body == player:
		near_exit = null
		map_ui.show_prompt(false)


func open_map() -> void:
	if busy or near_exit == null or not is_instance_valid(near_exit) or map_ui.is_open:
		return
	player.set_input_locked(true)
	map_ui.open_map(current_id)


func close_map() -> void:
	if busy or not map_ui.is_open:
		return
	map_ui.close_map()
	player.set_input_locked(false)
	map_ui.show_prompt(near_exit != null and is_instance_valid(near_exit))


func travel_to(destination: StringName) -> bool:
	if (
		busy
		or not map_ui.is_open
		or near_exit == null
		or destination == current_id
		or not location_paths.has(destination)
	):
		return false
	busy = true
	map_ui.set_loading()
	await get_tree().process_frame
	if not ResourceLoader.exists(location_paths[destination], "PackedScene"):
		return travel_failed("No se pudo cargar el destino")
	var packed: PackedScene = load(location_paths[destination])
	if packed == null:
		return travel_failed("No se pudo cargar el destino")
	var incoming: Node3D = packed.instantiate()
	if incoming == null or not incoming.has_node("Arrival") or not incoming.has_node("Exit"):
		if incoming != null:
			incoming.queue_free()
		return travel_failed("El destino no tiene entrada o salida")
	var old := active_location
	slot.remove_child(old)
	slot.add_child(incoming)
	await get_tree().physics_frame
	var arrival: Marker3D = incoming.get_node("Arrival")
	var ray := PhysicsRayQueryParameters3D.create(
		arrival.global_position + Vector3.UP * 2, arrival.global_position - Vector3.UP * 3, 1
	)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray)
	if (
		hit.is_empty()
		or hit.normal.y < 0.6
		or absf(hit.position.y - arrival.global_position.y) > 1.2
	):
		slot.remove_child(incoming)
		incoming.queue_free()
		slot.add_child(old)
		return travel_failed("No hay suelo seguro en la entrada")
	active_location = incoming
	current_id = destination
	old.queue_free()
	player.global_position = hit.position + Vector3.UP * 0.05
	player.velocity = Vector3.ZERO
	player.reset_physics_interpolation()
	camera_rig.avoid_world_geometry = current_id == &"home"
	camera_rig.snap_to_target()
	watch_exit(incoming)
	map_ui.close_map()
	player.set_input_locked(false)
	busy = false
	return true


func travel_failed(message: String) -> bool:
	map_ui.show_error(message)
	busy = false
	return false
