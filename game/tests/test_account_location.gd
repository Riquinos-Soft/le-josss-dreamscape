extends SceneTree
## Exercise the account actor against the authored palace, including both stairs.

const Place = preload("res://v2/locations/lourizan.gd")
const Catalog = preload("res://v2/characters/appearance_catalog.gd")
const Destinations = preload("res://v2/locations/destinations.gd")
var scene: Node3D
var actor: CharacterBody3D
var failures := 0
var checks := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	scene = load("res://v2/account/session.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	scene.get_node("Daylight").preview_hour = 13.0
	scene.handle_packet(
		{
			"type": "welcome",
			"character":
			{
				"appearance": Catalog.preset(),
				"position": [9.6, 0.05, 0],
				"saved_at": "2026-10-17T12:00:00Z"
			}
		}
	)
	actor = scene.actor
	actor.spawn_position = Place.ARRIVAL
	actor.set_physics_process(true)
	scene.presenter.set_physics_process(true)
	scene.input_adapter.set_physics_process(false)
	await frames(80)
	check(actor.is_on_floor(), "account arrival is grounded in the palace forecourt")
	check(Place.contains_saved_position(actor.position), "arrival fits the persistence bounds")
	check(not Place.contains_saved_position(Vector3(INF, 0, 0)), "nonfinite positions rejected")
	check(not Place.contains_saved_position(Vector3(40, 0, 0)), "outside positions rejected")
	trace("arrival")
	await capture("arrival-day")
	check(
		Destinations.PATHS.size() == 3 and not Destinations.PATHS.has("home"),
		"only the three public destinations exist"
	)
	check(
		scene.world_view.location.has_node("LucasMaconheiro"), "full original Pazo includes Lucas"
	)
	check(
		scene.world_view.location.has_node("Salon/BraisAnfitrion"),
		"full original salon includes Brais"
	)
	for side in [-1, 1]:
		for point in [
			Vector3(8.4, 0, side * 10.8),
			Vector3(6.72, 0, side * 10.8),
			Vector3(4.2, 0, side * 10.8),
			Vector3(0.6, 0, side * 10.8)
		]:
			if not await walk_to(point):
				finish()
				return
		check(actor.position.y > 4.1, "account actor climbs stair %d" % side)
		check(Place.contains_saved_position(actor.position), "terrace position can be saved")
		await capture("terrace-%d" % side)
		for point in [Vector3(4.2, 0, side * 10.8), Vector3(8.4, 0, side * 10.8)]:
			if not await walk_to(point):
				finish()
				return
		check(actor.position.y < 0.3, "account actor descends stair %d" % side)
	await walk_to(Place.ARRIVAL)
	await frames(45)
	check(
		scene.camera_rig.global_position.distance_to(actor.position + Vector3.UP * 0.9) < 0.1,
		"camera follows the saved character around the authored location"
	)
	root.size = Vector2i(844, 390)
	scene.get_node("Daylight").preview_hour = 1.0
	await frames(80)
	check(scene.get_node("Daylight").daylight < 0.1, "account world uses local day/night grade")
	await capture("arrival-night-compact")
	await inspect_restored_world()
	finish()


func inspect_restored_world() -> void:
	scene.get_node("Daylight").preview_hour = 13.0
	for path in Destinations.SPEAKERS.lourizan:
		var npc: Node3D = scene.world_view.location.get_node(path)
		actor.position = npc.global_position + Vector3(1.25, 0.05, 0)
		actor.velocity = Vector3.ZERO
		scene.camera_rig.snap_to_target()
		await frames(12)
		check(npc.can_talk(actor), "restored resident remains reachable: " + path)
		var pages: Array = (
			["Bienvenido a Lourizán."]
			if npc.dialogue_pages.is_empty()
			else Array(npc.dialogue_pages)
		)
		scene.handle_packet({"type": "talked", "speaker": path, "pages": pages})
		check(scene.world_view.dialogue.is_open, "account dialogue opens for " + path)
		check(not scene.input_adapter.is_physics_processing(), "dialogue locks account controls")
		await capture(path.replace("/", "-") + "-conversation")
		scene.world_view.dialogue.close()
		scene.input_adapter.set_physics_process(false)
	var identity := actor.get_instance_id()
	for place in ["street", "scandale", "lourizan"]:
		var arrival: Array = {
			"street": [4.35, 2.4, 0], "scandale": [1, .05, 3.5], "lourizan": [9.6, .05, 0]
		}[place]
		scene.handle_packet({"type": "travelled", "place": place, "position": arrival})
		scene.input_adapter.set_physics_process(false)
		await frames(20)
		check(
			actor.get_instance_id() == identity and actor.is_on_floor(),
			"travel retains grounded player: " + place
		)
		check(String(scene.current_id) == place, "acknowledged destination loads: " + place)
		await capture(place + "-restored")
		var exit: Area3D = scene.world_view.location.get_node("Exit")
		actor.position = exit.global_position + Vector3.UP * .05
		actor.velocity = Vector3.ZERO
		scene.camera_rig.snap_to_target()
		await frames(12)
		scene.world_view.open_map()
		check(scene.world_view.map_ui.is_open, "marked account exit opens map: " + place)
		await capture(place + "-map")
		if place == "scandale":
			root.size = Vector2i(390, 844)
			await frames(8)
			var rect: Rect2 = scene.world_view.map_ui.scandale_button.get_global_rect()
			check(
				rect.position.x >= 0 and rect.end.x <= root.get_visible_rect().size.x,
				"map fits portrait width"
			)
			var physical_scale := float(root.size.x) / root.get_visible_rect().size.x
			check(
				rect.size.y * physical_scale >= 43.9,
				"portrait travel targets retain 44 screen pixels"
			)
			check(
				scene.world_view.map_ui.ui_theme.default_font_size * physical_scale >= 15.5,
				"portrait map text remains readable"
			)
			await capture("map-portrait")
			root.size = Vector2i(844, 390)
		scene.world_view.close_map()
		scene.input_adapter.set_physics_process(false)
	scene.world_view.pending = true
	scene.connection_error("test_interruption")
	check(
		not scene.world_view.pending and not scene.input_adapter.is_physics_processing(),
		"disconnect clears pending actions and locks input"
	)
	scene.handle_packet(
		{
			"type": "welcome",
			"character":
			{
				"appearance": Catalog.preset(),
				"place": "lourizan",
				"position": [actor.position.x, actor.position.y, actor.position.z],
				"saved_at": "test"
			}
		}
	)
	check(
		scene.input_adapter.is_physics_processing(),
		"fresh welcome restores controls after interruption"
	)


func walk_to(point: Vector3) -> bool:
	for index in 700:
		var offset := point - actor.position
		offset.y = 0
		if offset.length() < 0.18:
			actor.set_movement_intent(Vector3.ZERO)
			await frames(8)
			trace("route " + str(point))
			check(actor.is_on_floor(), "grounded route to %s" % point)
			return true
		actor.set_movement_intent(offset.normalized() * minf(1, offset.length() * 4))
		await physics_frame
	actor.set_movement_intent(Vector3.ZERO)
	check(false, "route blocked at %s toward %s" % [actor.position, point])
	return false


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless" or "--capture" not in OS.get_cmdline_user_args():
		return
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path("res://../build/verification/v2/lourizan")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)


func finish() -> void:
	print("Account Lourizan: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func trace(label: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		print("Account route @%dms: %s" % [Time.get_ticks_msec(), label])
