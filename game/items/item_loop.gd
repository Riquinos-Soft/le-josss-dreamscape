extends Node
## Courtyard-only coordination. Transfers are synchronous; previews own no item.
const Definition = preload("res://items/item_definition.gd")
const Item = preload("res://items/item_instance.gd")
const Inventory = preload("res://inventory/inventory.gd")
const WorldItem = preload("res://items/world_item.gd")
const REACH: float = 2.0

var inventory := Inventory.new()
var world_item: WorldItem
var preview: MeshInstance3D
var placement_active: bool = false
var target := Vector3.ZERO
var yaw: float = 0.0
var target_valid: bool = false
var commands: Array[StringName] = []
var status: Label
var place_button: Button
@onready var player = get_parent().get_node("Player")
@onready var camera: Camera3D = get_parent().get_node("CameraRig/Camera")
@onready var floor_body: StaticBody3D = get_parent().get_node("Geometry/Floor")


func _ready() -> void:
	world_item = WorldItem.new(Item.new(1, Definition.new()))
	get_parent().add_child.call_deferred(world_item)
	world_item.position = Vector3(0, 0.25, 1.5)
	build_hud()


func build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(12, 12)
	layer.add_child(panel)
	var rows := VBoxContainer.new()
	panel.add_child(rows)
	status = Label.new()
	rows.add_child(status)
	place_button = Button.new()
	place_button.text = "Place (P)"
	place_button.focus_mode = Control.FOCUS_NONE
	place_button.pressed.connect(func(): commands.append(&"begin"))
	rows.add_child(place_button)
	var help := Label.new()
	help.text = "WASD / arrows: walk | E: pickup\nP: place | Mouse: aim | Q/E: rotate 90°\nLeft click: confirm | Esc: cancel"
	rows.add_child(help)
	update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_E: commands.append(&"right" if placement_active else &"pickup")
			KEY_Q: commands.append(&"left")
			KEY_P: commands.append(&"begin")
			KEY_ESCAPE: commands.append(&"cancel")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if placement_active:
			commands.append(&"confirm")


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		commands.clear()


func _physics_process(_delta: float) -> void:
	if placement_active:
		var mouse := get_viewport().get_mouse_position()
		var hit = Plane(Vector3.UP, 0).intersects_ray(camera.project_ray_origin(mouse), camera.project_ray_normal(mouse))
		target = hit + Vector3.UP * 0.25 if hit != null else Vector3(1000, 0.25, 1000)
	for command in commands:
		match command:
			&"pickup": pickup()
			&"begin": begin_placement()
			&"left": rotate_preview(-1)
			&"right": rotate_preview(1)
			&"cancel": cancel_placement()
			&"confirm": confirm_placement()
	commands.clear()
	if placement_active:
		preview.position = target
		preview.rotation.y = yaw
		target_valid = valid_pose(target, yaw)
		preview.material_override.albedo_color = Color(0.3, 0.9, 0.65) if target_valid else Color(1, 0.22, 0.18)
	update_hud()


func clear_path(point: Vector3) -> bool:
	var from: Vector3 = player.global_position + Vector3.UP * 0.3
	var to := Vector3(point.x, 0.3, point.z)
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	return player.get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func can_pickup() -> bool:
	return not placement_active and inventory.item == null and is_instance_valid(world_item) \
		and world_item.is_inside_tree() \
		and world_item.item != null and player.global_position.distance_to(world_item.global_position) <= REACH \
		and clear_path(world_item.global_position)


func pickup() -> bool:
	if not can_pickup() or not inventory.put(world_item.item):
		return false
	world_item.item = null
	world_item.collision_layer = 0
	world_item.get_parent().remove_child(world_item)
	world_item.queue_free()
	world_item = null
	return true


func begin_placement() -> bool:
	if placement_active or inventory.item == null:
		return false
	placement_active = true
	player.movement_enabled = false
	yaw = 0.0
	target = player.global_position - player.visual.global_basis.z * 1.3
	target.y = 0.25
	preview = WorldItem.make_visual(Color(0.3, 0.9, 0.65))
	preview.name = "PlacementPreview"
	get_parent().add_child(preview)
	preview.position = target
	return true


func rotate_preview(steps: int) -> void:
	if placement_active:
		yaw = wrapf(yaw + steps * PI / 2.0, 0.0, TAU)


func valid_pose(point: Vector3, angle: float) -> bool:
	if not point.is_finite() or not is_equal_approx(point.y, 0.25):
		return false
	var ground := Vector3(point.x, player.global_position.y, point.z)
	if player.global_position.distance_to(ground) > REACH or not clear_path(point):
		return false
	var basis := Basis(Vector3.UP, angle)
	var half := Definition.SIZE * 0.5
	for x in [-half.x, half.x]:
		for z in [-half.z, half.z]:
			var corner := point + basis * Vector3(x, 0, z)
			if absf(corner.x) > 10.0 or absf(corner.z) > 8.0:
				return false
	var shape := BoxShape3D.new()
	shape.size = Definition.SIZE
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(basis, point)
	query.collision_mask = 7
	query.exclude = [floor_body.get_rid()]
	query.margin = 0.015
	return player.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


func confirm_placement() -> bool:
	if not placement_active or inventory.item == null or not valid_pose(target, yaw):
		return false
	var held := inventory.item
	var representation := WorldItem.new(held)
	# Construct first; only commit once validation and construction have succeeded.
	if inventory.take(held) != held:
		representation.free()
		return false
	world_item = representation
	get_parent().add_child(world_item)
	world_item.position = target
	world_item.rotation.y = yaw
	world_item.reset_physics_interpolation()
	cancel_placement()
	return true


func cancel_placement() -> void:
	if is_instance_valid(preview):
		preview.get_parent().remove_child(preview)
		preview.queue_free()
	preview = null
	placement_active = false
	player.movement_enabled = true


func update_hud() -> void:
	place_button.disabled = inventory.item == null or placement_active
	if placement_active:
		status.text = "Inventory: Dream block #%d\nPlacement: %s" % [inventory.item.session_id, "valid" if target_valid else "invalid"]
	elif inventory.item != null:
		status.text = "Inventory: Dream block #%d" % inventory.item.session_id
	else:
		status.text = "Inventory: empty\n" + ("E: pick up Dream block" if can_pickup() else "Approach the purple block")
