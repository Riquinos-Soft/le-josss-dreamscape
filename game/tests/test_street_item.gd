extends SceneTree
## Round trips on the real sloping street, preserving the existing item identity.

var checks := 0
var failures := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var street = load("res://world/jacobo_risa_street.tscn").instantiate()
	root.add_child(street)
	current_scene = street
	await frames(20)
	var loop = street.get_node("ItemLoop")
	loop.set_physics_process(false)
	var player = street.get_node("Player")
	var original = loop.world_item.item
	check(loop.can_pickup(), "block is reachable at spawn")
	check(loop.world_item.position.y > 1.5, "block rests on elevated street")
	await capture("street_block_spawn")
	for cycle in 3:
		check(loop.pickup(), "pickup from street")
		check(loop.inventory.item == original and loop.world_item == null, "pickup keeps identity")
		check(loop.begin_placement(), "start street placement")
		var placement: Vector3 = loop.supported_pose(Vector3(2.25, 0, 1.1), cycle * PI / 2)
		check(placement != loop.INVALID_TARGET, "complete footprint supported on slope")
		loop.yaw = cycle * PI / 2
		loop.target = placement
		if cycle == 0:
			loop.preview.position = placement
			loop.target_valid = loop.valid_pose(placement, loop.yaw)
			await capture("street_block_preview")
		check(loop.confirm_placement(), "confirm supported slope placement")
		check(
			loop.world_item.item == original and loop.inventory.item == null,
			"placement keeps identity"
		)
		check(
			loop.world_item.position.is_equal_approx(placement),
			"committed elevation matches preview"
		)
		await frames(2)
		if cycle == 0:
			await capture("street_block_moved")
	check(loop.pickup(), "pick up after repeated moves")
	loop.begin_placement()
	loop.target = Vector3(100, 2, 100)
	check(not loop.confirm_placement(), "reject outside street")
	loop.target = loop.supported_pose(Vector3(3.3, 0, 1.1), 0.0) + Vector3.UP
	check(not loop.confirm_placement(), "reject floating placement")
	loop.target = loop.supported_pose(player.position, 0.0)
	check(not loop.confirm_placement(), "reject overlap with player")
	var edge: Vector3 = loop.supported_pose(Vector3(4.4, 0, 0), 0.0)
	check(edge == loop.INVALID_TARGET, "reject footprint crossing road edge")
	check(loop.inventory.item == original, "invalid placement cannot lose the item")
	loop.cancel_placement()
	check(
		loop.inventory.item == original and loop.preview == null,
		"cancel keeps item and removes preview"
	)
	# Place and retrieve on the garage apron too, at a different world height.
	player.position = Vector3(-2.5, 0.9, 25.5)
	player.velocity = Vector3.ZERO
	await frames(10)
	loop.begin_placement()
	loop.target = loop.supported_pose(Vector3(-1.2, 0, 25.5), 0.0)
	check(loop.target != loop.INVALID_TARGET, "garage apron supports footprint")
	check(loop.confirm_placement(), "place on lower garage apron")
	await frames(2)
	check(loop.pickup() and loop.inventory.item == original, "retrieve same item at garage")
	print("Street item: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func capture(label: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args():
		return
	current_scene.get_node("ItemLoop").update_hud()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(
		ProjectSettings.globalize_path("res://../build/verification/%s.png" % label)
	)


func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)
