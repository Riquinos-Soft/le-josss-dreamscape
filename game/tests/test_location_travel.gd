extends "res://tests/test_home_exterior.gd"
## Input-driven Casa <-> Lourizán route, map cancel, repeat travel and failure recovery.

var session: Node3D
var map_ui: CanvasLayer


func run() -> void:
	session = load("res://world/dreamscape.tscn").instantiate()
	scene = session
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Player")
	camera = scene.get_node("CameraRig/Camera")
	map_ui = scene.get_node("TravelMap")
	var original_player := player.get_instance_id()
	await frames(45)
	check(player.is_on_floor(), "session starts grounded at home")
	session.open_map()
	check(not map_ui.is_open, "map requires an exit")
	if not await walk_home_exit():
		finish()
		return
	check(session.near_exit != null, "home exit activates on approach")
	session.open_map()
	check(map_ui.is_open and player.input_locked, "map freezes player")
	await capture("05-travel-map")
	var cancel_position := player.position
	session.close_map()
	check(not map_ui.is_open and not player.input_locked, "cancel resumes play")
	check(player.position.distance_to(cancel_position) < 0.03, "cancel keeps position")
	for cycle in 3:
		if session.near_exit == null:
			if not await walk_home_exit():
				finish()
				return
		session.open_map()
		map_ui.select(&"lourizan")
		check(map_ui.selected == &"lourizan", "destination selected")
		if not await session.travel_to(&"lourizan"):
			check(false, "travel to Lourizán succeeded")
			finish()
			return
		await frames(12)
		check(session.current_id == &"lourizan", "arrived in Lourizán")
		if cycle == 0:
			await capture("06-lourizan-arrival")
		check(player.get_instance_id() == original_player, "same player preserved")
		check(session.near_exit == null and not map_ui.is_open, "arrival does not loop")
		check(player.is_on_floor(), "Lourizán arrival grounded")
		check(
			(
				camera.get_parent().global_position.distance_to(player.position + Vector3.UP * 0.9)
				< 0.2
			),
			"camera snaps to arrival"
		)
		if not await walk_lourizan_exit():
			finish()
			return
		if cycle == 0:
			session.open_map()
			map_ui.select(&"home")
			var original_path: String = session.location_paths[&"home"]
			session.location_paths[&"home"] = "res://world/locations/missing.tscn"
			check(not await session.travel_to(&"home"), "missing destination rejected")
			check(session.current_id == &"lourizan", "failed travel keeps origin")
			check(map_ui.is_open and not session.busy, "failure is recoverable")
			session.location_paths[&"home"] = original_path
		else:
			session.open_map()
		map_ui.select(&"home")
		if not await session.travel_to(&"home"):
			check(false, "return to home succeeded")
			finish()
			return
		await frames(12)
		check(session.current_id == &"home", "returned home")
		check(player.get_instance_id() == original_player, "return keeps player")
		check(player.is_on_floor(), "home arrival grounded")
		check(session.near_exit == null, "home arrival away from exit")
	check(session.get_node("LocationSlot").get_child_count() == 1, "one location remains")
	finish()


func walk_home_exit() -> bool:
	for z in [10, 8, 6, 4, 2, 0, -2, -4, -6, -8]:
		if not await walk_to(Vector3(8, 0, z)):
			return false
	return true


func walk_lourizan_exit() -> bool:
	for z in [-10, -8, -6, -4]:
		if not await walk_to(Vector3(6, 0, z)):
			return false
	return true


func finish() -> void:
	release_inputs()
	print("Location travel: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
