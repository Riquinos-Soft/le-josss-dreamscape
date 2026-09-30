extends SceneTree
## Isolated collision fixtures for the scan-only step and edge options.

var failures := 0
var checks := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var world := Node3D.new()
	root.add_child(world)
	current_scene = world
	add_box(world, Vector3(2, -0.2, 0), Vector3(8, 0.4, 4))
	add_box(world, Vector3(2, 0.1, 0), Vector3(2, 0.2, 4))
	add_box(world, Vector3(4.5, 1, 0), Vector3(0.3, 2, 4))
	var orientation := Node3D.new()
	world.add_child(orientation)
	var player = load("res://player/player.tscn").instantiate()
	player.position = Vector3(0, 0.05, 0)
	player.movement_orientation = orientation
	player.step_height = 0.25
	player.prevent_ledge_fall = true
	world.add_child(player)
	await frames(15)
	Input.action_press("move_right")
	await frames(40)
	check(
		player.position.x > 1.5 and player.position.y > 0.18,
		"climb 20cm step: %s" % player.position
	)
	await frames(35)
	Input.action_release("move_right")
	check(player.position.x > 3.7 and player.position.x < 4.05, "tall wall blocks step solver")
	check(player.position.y < 0.1, "descend the step")
	Input.action_press("move_back")
	await frames(90)
	Input.action_release("move_back")
	check(player.position.z > 1.3 and player.position.z < 1.6, "stop before unsupported edge")
	check(player.is_on_floor(), "edge guard keeps feet supported")
	print("Scan movement: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func add_box(parent: Node3D, position: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = position
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
