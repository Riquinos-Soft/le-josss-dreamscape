extends SceneTree
## Full session route: street bag -> Pazo placement -> Casa -> Pazo recovery -> street.

const Item = preload("res://items/item_instance.gd")
const Definition = preload("res://items/item_definition.gd")

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
	var beer = items.world_item.item
	check(items.pickup(), "street beer enters bag")
	check(items.inventory.get_item(0) == beer, "street pickup keeps exact reference")
	check(items.world_items.is_empty(), "street becomes empty after pickup")
	await enter_exit(session.get_node("Street/Exit"))
	session.open_map()
	session.map_ui.select(&"lourizan")
	check(await session.travel_to(&"lourizan"), "bag travels to Lourizán")
	await frames(10)
	check(items.inventory.get_item(0) == beer, "bag identity survives travel")
	check(items.active_location_id == &"lourizan", "item context follows destination")
	check(not items.support_bodies.is_empty(), "Pazo exposes placement supports")
	check(items.begin_placement(0), "select beer for Pazo placement")
	var pazo_target: Vector3 = items.supported_pose(
		player.global_position + Vector3(-1.0, 0, 0), 0.0
	)
	check(pazo_target != items.INVALID_TARGET, "Pazo forecourt supports bottle")
	items.target = pazo_target
	check(items.valid_pose(pazo_target, 0.0), "Pazo target validates")
	check(items.confirm_placement(), "beer places in Pazo")
	var pazo_transform: Transform3D = items.world_items[0].global_transform
	check(items.world_items[0].item == beer, "Pazo representation keeps identity")
	var second = items.create_item(Definition.new())
	check(items.inventory.put(second), "second test bottle enters stable slot")
	check(items.begin_placement(0), "second bottle selected")
	var second_target: Vector3 = items.supported_pose(
		player.global_position + Vector3(0, 0, 1.0), 0.0
	)
	items.target = second_target
	check(second_target != items.INVALID_TARGET, "second Pazo target supported")
	check(items.confirm_placement(), "second bottle places without replacing first")
	check(items.world_items.size() == 2, "two world objects coexist")
	await frames(2)
	check(not items.valid_pose(pazo_target, 0.0), "existing bottle blocks overlap")
	var guide: Node3D = session.active_location.get_node("LucasMaconheiro")
	var guide_ground: Vector3 = items.supported_pose(guide.global_position, 0.0)
	check(guide_ground != items.INVALID_TARGET, "ground beneath guide is discoverable")
	check(not items.valid_pose(guide_ground, 0.0), "guide collision blocks placement")
	await capture("pazo-beers")
	await enter_exit(session.active_location.get_node("Exit"))
	session.open_map()
	session.map_ui.select(&"home")
	check(await session.travel_to(&"home"), "travel from Pazo to Casa")
	await frames(10)
	check(items.world_items.is_empty(), "new Casa starts without duplicate seed")
	check(items.location_records[&"lourizan"].size() == 2, "Pazo stores two world records")
	var source_records: Array = items.location_records[&"lourizan"].duplicate()
	await enter_exit(session.active_location.get_node("Exit"))
	session.open_map()
	var original_path: String = session.location_paths[&"lourizan"]
	session.location_paths[&"lourizan"] = "res://world/locations/missing.tscn"
	check(not await session.travel_to(&"lourizan"), "failed destination rejected")
	check(session.current_id == &"home", "failed travel keeps source location")
	check(
		items.location_records[&"lourizan"].size() == source_records.size(),
		"failed travel keeps records"
	)
	session.location_paths[&"lourizan"] = original_path
	check(await session.travel_to(&"lourizan"), "return to Pazo")
	await frames(10)
	check(items.world_items.size() == 2, "Pazo restores both representations")
	check(
		items.world_items.any(func(node): return node.item == beer),
		"original beer reference restored"
	)
	var restored = items.world_items.filter(func(node): return node.item == beer)[0]
	check(restored.global_transform.is_equal_approx(pazo_transform), "beer pose survives unload")
	player.global_position = restored.global_position + Vector3(0.7, 0.05, 0)
	player.velocity = Vector3.ZERO
	await frames(4)
	check(items.pickup(), "restored Pazo beer can be picked up")
	check(items.inventory.find_item(beer) != -1, "same beer returns to bag")
	await enter_exit(session.active_location.get_node("Exit"))
	session.open_map()
	session.map_ui.select(&"street")
	check(await session.travel_to(&"street"), "return to street with beer")
	await frames(10)
	check(items.inventory.find_item(beer) != -1, "beer remains carried on street return")
	check(items.world_items.is_empty(), "empty initialized street does not respawn beer")
	check(items.location_records[&"lourizan"].size() == 1, "other Pazo bottle remains recorded")
	print("Bag travel: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func enter_exit(exit: Area3D) -> void:
	player.global_position = exit.global_position + Vector3.UP * 0.25
	player.velocity = Vector3.ZERO
	player.reset_physics_interpolation()
	await frames(5)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless" or "--capture" not in OS.get_cmdline_user_args():
		return
	await frames(10)
	RenderingServer.force_draw(false)
	var folder := ProjectSettings.globalize_path("res://../build/verification/bag")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
