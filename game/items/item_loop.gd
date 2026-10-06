extends Node
## Session item coordination. Instances have one committed owner: bag slot or world node.

signal bag_requested
signal feedback_requested(message: String)

const Definition = preload("res://items/item_definition.gd")
const Item = preload("res://items/item_instance.gd")
const Inventory = preload("res://inventory/inventory.gd")
const WorldItem = preload("res://items/world_item.gd")
const REACH := 2.0
const INVALID_TARGET := Vector3(1000, 1000, 1000)

@export var floor_path: NodePath = ^"../Geometry/Floor"
@export var initial_item_position := Vector3(0, 0.15, 1.5)
@export var hud_position := Vector2(12, 12)
@export_multiline var control_help := (
	"WASD / arrows or hold right mouse: walk | E: pickup"
	+ "\nB/P: bag | Mouse: aim | Q/E: rotate 90°"
	+ "\nLeft click: confirm | Esc: cancel"
)

var inventory := Inventory.new()
var world_items: Array[WorldItem] = []
var world_item: WorldItem:
	get:
		return world_items[0] if not world_items.is_empty() else null
var world_parent: Node3D
var support_bodies: Array[CollisionObject3D] = []
var active_location_id: StringName = &"street"
var location_records: Dictionary = {}
var initialized_locations: Dictionary = {&"street": true}
var next_session_id := 1
var preview: MeshInstance3D
var placement_active := false
var selected_slot := -1
var target := Vector3.ZERO
var yaw := 0.0
var target_valid := false
var commands: Array[StringName] = []
var status: Label
var place_button: Button
var touch_mode := false
var touch_aim := Vector2.ZERO
var touch_aim_set := false
var touch_aim_pending := false
@onready var player = get_parent().get_node("Player")
@onready var camera: Camera3D = get_parent().get_node("CameraRig/Camera")
@onready var floor_body: StaticBody3D = get_node(floor_path)


func _ready() -> void:
	world_parent = get_parent()
	support_bodies.assign([floor_body])
	var initial := WorldItem.new(create_item())
	world_items.append(initial)
	world_parent.add_child.call_deferred(initial)
	initial.position = initial_item_position
	_build_hud()


func create_item(definition: Definition = null) -> Item:
	var item_definition := definition if definition != null else Definition.new()
	var item := Item.new(next_session_id, item_definition)
	next_session_id += 1
	return item


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	layer.layer = 1
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = hud_position
	layer.add_child(panel)
	var rows := VBoxContainer.new()
	panel.add_child(rows)
	status = Label.new()
	rows.add_child(status)
	place_button = Button.new()
	place_button.text = "Bolsa (B/P)"
	place_button.focus_mode = Control.FOCUS_NONE
	place_button.pressed.connect(func(): bag_requested.emit())
	rows.add_child(place_button)
	var help := Label.new()
	help.text = control_help
	rows.add_child(help)
	update_hud()


func bind_initial_context(
	location_id: StringName, container: Node3D, supports: Array[CollisionObject3D]
) -> void:
	active_location_id = location_id
	world_parent = container
	support_bodies = supports
	for representation in world_items:
		if representation.is_inside_tree() and representation.get_parent() != container:
			representation.reparent(container, true)


func commit_location_change(
	location_id: StringName, container: Node3D, supports: Array[CollisionObject3D]
) -> void:
	location_records[active_location_id] = _snapshot_world_items()
	_clear_world_items()
	active_location_id = location_id
	world_parent = container
	support_bodies = supports
	if not initialized_locations.has(location_id):
		initialized_locations[location_id] = true
		location_records[location_id] = []
	_restore_world_items(location_records.get(location_id, []))


func _snapshot_world_items() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for representation in world_items:
		if is_instance_valid(representation) and representation.item != null:
			records.append(
				{"item": representation.item, "transform": representation.global_transform}
			)
	return records


func _restore_world_items(records: Array) -> void:
	for record in records:
		var representation := WorldItem.new(record.item)
		world_parent.add_child(representation)
		representation.global_transform = record.transform
		representation.reset_physics_interpolation()
		world_items.append(representation)


func _clear_world_items() -> void:
	for representation in world_items:
		if is_instance_valid(representation):
			representation.collision_layer = 0
			representation.queue_free()
	world_items.clear()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_E:
				commands.append(&"right" if placement_active else &"pickup")
			KEY_Q:
				commands.append(&"left")
			KEY_B, KEY_P:
				bag_requested.emit()
			KEY_ESCAPE:
				commands.append(&"cancel")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if placement_active:
			commands.append(&"confirm")


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		commands.clear()
		if placement_active:
			cancel_placement()


func _physics_process(_delta: float) -> void:
	if placement_active:
		if not touch_mode or touch_aim_pending:
			target = _placement_target_from_mouse()
			touch_aim_pending = false
		elif not touch_aim_set:
			target = initial_placement_target()
	for command in commands:
		match command:
			&"pickup":
				pickup()
			&"begin":
				begin_placement()
			&"left":
				rotate_preview(-1)
			&"right":
				rotate_preview(1)
			&"cancel":
				cancel_placement()
			&"confirm":
				confirm_placement()
	commands.clear()
	if placement_active:
		preview.global_position = target
		preview.global_rotation = Vector3(0, yaw, 0)
		target_valid = valid_pose(target, yaw)
		WorldItem.tint_visual(
			preview, Color(0.3, 0.9, 0.65) if target_valid else Color(1, 0.22, 0.18)
		)
	update_hud()


func _clear_path(point: Vector3) -> bool:
	var from: Vector3 = player.global_position + Vector3.UP * 0.3
	var to := point + Vector3.UP * 0.05
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	return player.get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _is_support(collider: Object) -> bool:
	return collider is CollisionObject3D and support_bodies.has(collider)


func _placement_target_from_mouse() -> Vector3:
	var mouse := touch_aim if touch_mode else get_viewport().get_mouse_position()
	var origin := camera.project_ray_origin(mouse)
	var direction := camera.project_ray_normal(mouse)
	var excluded: Array[RID] = []
	for attempt in 16:
		var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 120.0, 1)
		query.exclude = excluded
		var hit: Dictionary = player.get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty():
			break
		if _is_support(hit.collider) and hit.normal.y >= 0.9:
			return _preview_pose(hit.position)
		if _is_support(hit.collider):
			origin = hit.position + direction * 0.01
		else:
			excluded.append(hit.rid)
	var fallback: Variant = Plane(Vector3.UP, player.global_position.y).intersects_ray(
		camera.project_ray_origin(mouse), camera.project_ray_normal(mouse)
	)
	return _preview_pose(fallback) if fallback != null else INVALID_TARGET


func pickup_candidate() -> WorldItem:
	var best: WorldItem
	var best_distance := INF
	for representation in world_items:
		if (
			is_instance_valid(representation)
			and representation.is_inside_tree()
			and representation.item != null
			and player.global_position.distance_to(representation.global_position) <= REACH
			and _clear_path(representation.global_position)
		):
			var distance: float = player.global_position.distance_squared_to(
				representation.global_position
			)
			if (
				distance < best_distance
				or (
					is_equal_approx(distance, best_distance)
					and best != null
					and representation.item.session_id < best.item.session_id
				)
			):
				best = representation
				best_distance = distance
	return best


func can_pickup() -> bool:
	return not placement_active and inventory.first_free_slot() != -1 and pickup_candidate() != null


func pickup() -> bool:
	var candidate := pickup_candidate()
	if candidate == null:
		return false
	if inventory.first_free_slot() == -1:
		feedback_requested.emit("Bolsa llena")
		return false
	var item: Item = candidate.item
	if not inventory.put(item):
		return false
	candidate.item = null
	candidate.collision_layer = 0
	world_items.erase(candidate)
	candidate.get_parent().remove_child(candidate)
	candidate.queue_free()
	feedback_requested.emit("Guardado en la bolsa")
	return true


func begin_placement(slot_index: int = 0) -> bool:
	if placement_active or inventory.get_item(slot_index) == null:
		return false
	selected_slot = slot_index
	placement_active = true
	touch_aim_set = false
	touch_aim_pending = false
	yaw = 0.0
	target = initial_placement_target()
	preview = WorldItem.make_visual(
		inventory.get_item(selected_slot).definition, Color(0.3, 0.9, 0.65)
	)
	preview.name = "PlacementPreview"
	world_parent.add_child(preview)
	preview.global_position = target
	return true


func initial_placement_target() -> Vector3:
	var point: Vector3 = player.global_position - player.visual.global_basis.z * 1.3
	return _preview_pose(point)


func _current_definition() -> Definition:
	var selected: Item = inventory.get_item(selected_slot)
	if selected != null:
		return selected.definition
	var candidate := pickup_candidate()
	return candidate.item.definition if candidate != null else Definition.new()


func _preview_pose(point: Vector3) -> Vector3:
	var supported := supported_pose(point, yaw)
	var half_height: float = _current_definition().size.y * 0.5
	return point + Vector3.UP * half_height if supported == INVALID_TARGET else supported


func _support_hit_at(point: Vector3) -> Dictionary:
	var origin := Vector3(point.x, maxf(point.y, player.global_position.y) + 2.0, point.z)
	var end := Vector3(point.x, minf(point.y, player.global_position.y) - 3.0, point.z)
	var excluded: Array[RID] = []
	for attempt in 16:
		var query := PhysicsRayQueryParameters3D.create(origin, end, 1)
		query.exclude = excluded
		var hit: Dictionary = player.get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty():
			return {}
		if _is_support(hit.collider):
			return hit
		excluded.append(hit.rid)
	return {}


func supported_pose(point: Vector3, angle: float) -> Vector3:
	if not point.is_finite():
		return INVALID_TARGET
	var basis := Basis(Vector3.UP, angle)
	var half := _current_definition().size * 0.5
	var highest := -INF
	var lowest := INF
	for offset in [
		Vector3.ZERO,
		Vector3(-half.x, 0, -half.z),
		Vector3(half.x, 0, -half.z),
		Vector3(-half.x, 0, half.z),
		Vector3(half.x, 0, half.z)
	]:
		var corner: Vector3 = point + basis * offset
		var hit := _support_hit_at(corner)
		if hit.is_empty() or hit.normal.y < 0.9:
			return INVALID_TARGET
		highest = maxf(highest, hit.position.y)
		lowest = minf(lowest, hit.position.y)
	if highest - lowest > 0.12:
		return INVALID_TARGET
	return Vector3(point.x, highest + half.y, point.z)


func rotate_preview(steps: int) -> void:
	if not placement_active:
		return
	yaw = wrapf(yaw + steps * PI / 2.0, 0.0, TAU)
	var supported := supported_pose(target, yaw)
	if supported != INVALID_TARGET:
		target = supported


func valid_pose(point: Vector3, angle: float) -> bool:
	if not point.is_finite():
		return false
	var ground := Vector3(point.x, player.global_position.y, point.z)
	if player.global_position.distance_to(ground) > REACH or not _clear_path(point):
		return false
	var supported := supported_pose(point, angle)
	if supported == INVALID_TARGET or absf(point.y - supported.y) > 0.015:
		return false
	var shape := BoxShape3D.new()
	shape.size = _current_definition().size - Vector3(0.01, 0.06, 0.01)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(Vector3.UP, angle), point + Vector3.UP * 0.031)
	query.collision_mask = 7
	query.margin = 0.001
	return player.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


func confirm_placement() -> bool:
	var selected_item: Item = inventory.get_item(selected_slot)
	if not placement_active or selected_item == null or not valid_pose(target, yaw):
		return false
	var representation := WorldItem.new(selected_item)
	if inventory.take_at(selected_slot, selected_item) != selected_item:
		representation.free()
		return false
	world_parent.add_child(representation)
	representation.global_transform = Transform3D(Basis(Vector3.UP, yaw), target)
	representation.reset_physics_interpolation()
	world_items.append(representation)
	cancel_placement()
	return true


func cancel_placement() -> void:
	if is_instance_valid(preview):
		preview.queue_free()
	preview = null
	placement_active = false
	selected_slot = -1


func update_hud() -> void:
	place_button.disabled = inventory.occupied_count() == 0 or placement_active
	if placement_active:
		var selected_item: Item = inventory.get_item(selected_slot)
		status.text = (
			"%s #%d\nColocación: %s"
			% [
				selected_item.definition.display_name,
				selected_item.session_id,
				"válida" if target_valid else "inválida"
			]
		)
	elif inventory.occupied_count() > 0:
		status.text = "Bolsa: %d/%d slots" % [inventory.occupied_count(), Inventory.CAPACITY]
	else:
		status.text = (
			"Bolsa vacía\n"
			+ ("E: guardar Birra Dreamscape" if can_pickup() else "Acércate a un objeto")
		)
