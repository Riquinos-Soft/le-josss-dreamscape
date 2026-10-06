extends SceneTree
## Active-location support validation for street, Casa and Lourizán terrain.

var checks := 0
var failures := 0
var session: Node3D
var player: CharacterBody3D
var items: Node


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	session = load("res://world/dreamscape.tscn").instantiate()
	root.add_child(session)
	current_scene = session
	player = session.get_node("Street/Player")
	items = session.get_node("Street/ItemLoop")
	await frames(25)
	check(items.pickup(), "beer picked up for support route")
	check(items.begin_placement(0), "street preview starts")
	var street_target: Vector3 = items.supported_pose(
		player.global_position + Vector3(0.8, 0, 0), 0.0
	)
	check(street_target != items.INVALID_TARGET, "street surface supports footprint")
	check(items.valid_pose(street_target, 0.0), "street surface validates")
	items.cancel_placement()
	await travel(&"home")
	check(items.active_location_id == &"home", "Casa support context active")
	check(not items.support_bodies.is_empty(), "Casa exposes captured terrain supports")
	check(items.begin_placement(0), "Casa preview starts")
	var home_target: Vector3 = items.supported_pose(
		player.global_position + Vector3(0, 0, -0.8), 0.0
	)
	check(home_target != items.INVALID_TARGET, "Casa path supports footprint")
	check(items.valid_pose(home_target, 0.0), "Casa path validates")
	check(
		(
			items.supported_pose(player.global_position + Vector3(100, 0, 100), 0.0)
			== items.INVALID_TARGET
		),
		"Casa empty edge rejects placement"
	)
	items.cancel_placement()
	await travel(&"lourizan")
	check(items.active_location_id == &"lourizan", "Pazo support context active")
	check(items.begin_placement(0), "Pazo preview starts")
	var terrace_point: Vector3 = Vector3(6, 0, -4) * session.active_location.place_scale
	player.global_position = terrace_point + Vector3(0.8, 0.05, 0)
	player.velocity = Vector3.ZERO
	await frames(4)
	var terrace_target: Vector3 = items.supported_pose(terrace_point, 0.0)
	check(terrace_target != items.INVALID_TARGET, "Pazo terrace supports footprint")
	check(items.valid_pose(terrace_target, 0.0), "Pazo terrace validates")
	var guide: Node3D = session.active_location.get_node("LucasMaconheiro")
	player.global_position = guide.global_position + Vector3(0.8, 0.05, 0)
	await frames(3)
	var guide_target: Vector3 = items.supported_pose(guide.global_position, 0.0)
	check(guide_target != items.INVALID_TARGET, "terrain continues below Lucas")
	check(not items.valid_pose(guide_target, 0.0), "Lucas cannot become placement support")
	items.target = terrace_target + Vector3.UP
	check(not items.confirm_placement(), "floating Pazo placement rejected")
	check(items.inventory.get_item(0) != null, "invalid targets retain bag ownership")
	items.cancel_placement()
	print("Place support: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func travel(destination: StringName) -> void:
	var location: Node3D = (
		session.street if session.current_id == &"street" else session.active_location
	)
	player.global_position = location.get_node("Exit").global_position + Vector3.UP * 0.25
	player.velocity = Vector3.ZERO
	player.reset_physics_interpolation()
	await frames(5)
	session.open_map()
	session.map_ui.select(destination)
	check(await session.travel_to(destination), "travel to %s" % destination)
	await frames(10)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
