extends SceneTree
## Production street remains the host for the same player, sprite, camera and pixel pass.

var checks := 0
var failures := 0
var session: Node3D
var player: CharacterBody3D
var map_ui: CanvasLayer


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	session = load("res://world/dreamscape.tscn").instantiate()
	root.add_child(session)
	current_scene = session
	player = session.get_node("Street/Player")
	map_ui = session.get_node("TravelMap")
	await frames(25)
	await capture("street-production")
	var original_player := player.get_instance_id()
	var original_item = session.get_node("Street/ItemLoop").world_item.item
	check(session.current_id == &"street", "production street opens first")
	check(player.get_node("PixelCharacter").visible, "pixel sprite retained")
	check(session.get_node("Street/PixelPass").visible, "world pixel pass retained")
	check(
		session.get_node("Street/CameraRig/Camera").projection == Camera3D.PROJECTION_ORTHOGONAL,
		"production camera retained"
	)
	session.open_map()
	check(not map_ui.is_open, "map requires a marked exit")
	for cycle in 3:
		await enter_exit(session.get_node("Street/Exit"))
		check(session.near_exit != null, "street exit detected")
		session.open_map()
		check(map_ui.is_open and player.input_locked, "map freezes movement")
		if cycle == 0:
			var locked_position: Vector3 = player.global_position
			Input.action_press("move_forward")
			await frames(8)
			Input.action_release("move_forward")
			var horizontal := Vector2(
				player.global_position.x - locked_position.x,
				player.global_position.z - locked_position.z
			)
			check(horizontal.length() < 0.05, "map input does not move player")
		if cycle == 0:
			await capture("travel-map")
			session.close_map()
			check(not map_ui.is_open and not player.input_locked, "cancel returns to play")
			session.open_map()
		map_ui.select(&"lourizan")
		if cycle == 0:
			var original_path: String = session.location_paths[&"lourizan"]
			session.location_paths[&"lourizan"] = "res://world/locations/missing.tscn"
			check(not await session.travel_to(&"lourizan"), "missing location rejected")
			check(map_ui.is_open and session.current_id == &"street", "failed trip keeps origin")
			session.location_paths[&"lourizan"] = original_path
		check(await session.travel_to(&"lourizan"), "travel to Lourizán")
		await frames(12)
		if cycle == 0:
			await capture("lourizan-pixel-pass")
		check(session.current_id == &"lourizan", "Lourizán active")
		check(player.get_instance_id() == original_player, "player identity retained")
		check(player.is_on_floor(), "Lourizán arrival grounded")
		check(not session.get_node("Street/Walkway").visible, "street world hidden")
		check(session.get_node("Street/PixelPass").visible, "pixel pass still active")
		check(
			session.get_node("Street/TouchHUD/TouchControls").travel_only,
			"touch travel mode active"
		)
		check(session.near_exit == null, "arrival does not reopen map")
		await enter_exit(session.active_location.get_node("Exit"))
		check(session.near_exit != null, "Lourizán exit detected")
		session.open_map()
		map_ui.select(&"street")
		check(await session.travel_to(&"street"), "return to production street")
		await frames(12)
		check(session.current_id == &"street", "street active again")
		check(player.get_instance_id() == original_player, "same player returns")
		check(
			session.get_node("Street/ItemLoop").world_item.item == original_item,
			"street item identity returns"
		)
		check(player.is_on_floor(), "street arrival grounded")
		check(session.get_node("Street/Walkway").visible, "street art restored")
		check(
			not session.get_node("Street/TouchHUD/TouchControls").travel_only,
			"street touch actions restored"
		)
		check(session.get_node("LocationSlot").get_child_count() == 0, "no stale location remains")
	print("Location travel: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func enter_exit(exit: Area3D) -> void:
	player.global_position = exit.global_position + Vector3.UP * 0.25
	player.velocity = Vector3.ZERO
	player.reset_physics_interpolation()
	await frames(5)


func frames(count: int) -> void:
	for i in count:
		await physics_frame
	await process_frame


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless" or "--capture" not in OS.get_cmdline_user_args():
		return
	await frames(25)
	RenderingServer.force_draw(false)
	var folder := ProjectSettings.globalize_path("res://../build/verification/lourizan")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
