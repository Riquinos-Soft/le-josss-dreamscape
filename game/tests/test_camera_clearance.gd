extends SceneTree
## A solid wall changes orthographic framing and clears after it is removed.

var failures := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var scene: Node3D = load("res://world/courtyard.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	var rig: Node3D = scene.get_node("CameraRig")
	var camera: Camera3D = rig.get_node("Camera")
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.5
	rig.base_orthographic_size = 13.5
	rig.avoid_world_geometry = true
	rig.snap_to_target()
	var wall := StaticBody3D.new()
	wall.collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2, 3, 2)
	shape.shape = box
	wall.position = scene.get_node("Player").position + Vector3(4.5, 6, 6)
	wall.add_child(shape)
	scene.add_child(wall)
	await frames(35)
	check(rig.clear_fraction < 0.8, "wall blocks the desired camera path")
	check(camera.size < 13.0, "orthographic camera moves visibly closer")
	check(camera.position.length() < rig.camera_offset.length(), "camera clears wall")
	wall.queue_free()
	await frames(90)
	check(rig.clear_fraction == 1.0, "camera ray clears after wall removal")
	check(camera.size > 13.4, "camera eases back to original framing")
	rig.snap_to_target()
	check(camera.size == 13.5, "travel or respawn resets camera framing")
	print("Camera clearance: 6 checks, %d failures" % failures)
	quit(0 if failures == 0 else 1)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func check(passed: bool, label: String) -> void:
	if not passed:
		failures += 1
		push_error(label)
