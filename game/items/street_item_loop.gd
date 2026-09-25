extends "res://items/item_loop.gd"
## Street-specific support checks; ownership, controls and transfers use the existing loop.

const INVALID_TARGET := Vector3(1000, 1000, 1000)


func _ready() -> void:
	super()
	place_button.text = "Colocar (P)"
	# The authored collision is installed by the parent after children's _ready.
	call_deferred("settle_initial_item")


func settle_initial_item() -> void:
	await get_tree().physics_frame
	var supported := supported_pose(initial_item_position, 0.0)
	if supported != INVALID_TARGET and is_instance_valid(world_item):
		world_item.position = supported


func placement_target_from_mouse() -> Vector3:
	var mouse := touch_aim if touch_mode else get_viewport().get_mouse_position()
	var origin := camera.project_ray_origin(mouse)
	var direction := camera.project_ray_normal(mouse)
	var end := origin + direction * 100.0
	# The camera sees through faded side walls. Skip their vertical collision faces
	# when aiming; valid_pose still enforces the player's reach and clear path.
	for attempt in 8:
		var query := PhysicsRayQueryParameters3D.create(origin, end, 1)
		var hit: Dictionary = player.get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty() or hit.collider != floor_body:
			return INVALID_TARGET
		if hit.normal.y >= 0.9:
			return supported_pose(hit.position, yaw)
		origin = hit.position + direction * 0.01
	return INVALID_TARGET


func initial_placement_target() -> Vector3:
	return supported_pose(player.global_position - player.visual.global_basis.z * 1.3, yaw)


func supported_pose(point: Vector3, angle: float) -> Vector3:
	if not point.is_finite():
		return INVALID_TARGET
	var basis := Basis(Vector3.UP, angle)
	var half := Definition.SIZE * 0.5
	var highest := -INF
	var lowest := INF
	# Include the center and all four corners; never place partly beyond a road edge.
	for offset in [
		Vector3.ZERO,
		Vector3(-half.x, 0, -half.z),
		Vector3(half.x, 0, -half.z),
		Vector3(-half.x, 0, half.z),
		Vector3(half.x, 0, half.z)
	]:
		var corner: Vector3 = point + basis * offset
		var query := PhysicsRayQueryParameters3D.create(
			Vector3(corner.x, player.position.y + 1.0, corner.z),
			Vector3(corner.x, player.position.y - 2.0, corner.z),
			1
		)
		var hit: Dictionary = player.get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty() or hit.collider != floor_body or hit.normal.y < 0.9:
			return INVALID_TARGET
		highest = maxf(highest, hit.position.y)
		lowest = minf(lowest, hit.position.y)
	if highest - lowest > 0.12:
		return INVALID_TARGET
	return Vector3(point.x, highest + half.y, point.z)


func valid_pose(point: Vector3, angle: float) -> bool:
	if not point.is_finite():
		return false
	var ground := Vector3(point.x, player.position.y, point.z)
	if player.position.distance_to(ground) > REACH or not clear_path(point):
		return false
	var supported := supported_pose(point, angle)
	if supported == INVALID_TARGET or absf(point.y - supported.y) > 0.015:
		return false
	var shape := BoxShape3D.new()
	shape.size = Definition.SIZE
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(Vector3.UP, angle), point)
	query.collision_mask = 7
	query.exclude = [floor_body.get_rid()]
	query.margin = 0.015
	return player.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


func update_hud() -> void:
	place_button.disabled = inventory.item == null or placement_active
	if placement_active:
		status.text = (
			"Bloque · " + ("Puedes colocarlo" if target_valid else "Busca suelo libre cercano")
		)
	elif inventory.item != null:
		status.text = "Llevas el bloque · P para colocarlo"
	else:
		status.text = "E · Recoger bloque" if can_pickup() else "Acércate al bloque violeta"
