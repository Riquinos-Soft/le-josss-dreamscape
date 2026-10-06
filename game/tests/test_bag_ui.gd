extends SceneTree

var checks := 0
var failures := 0
var session: Node3D
var bag: CanvasLayer
var items: Node
var player: CharacterBody3D


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	session = load("res://world/dreamscape.tscn").instantiate()
	root.add_child(session)
	current_scene = session
	bag = session.get_node("BagUI")
	items = session.get_node("Street/ItemLoop")
	player = session.get_node("Street/Player")
	await frames(20)
	await travel_to_street()
	check(bag.slot_buttons.size() == 8, "bag exposes eight stable slot controls")
	check(not bag.is_open and bag.open_button.visible, "closed bag icon is visible")
	check(bag.occupancy.text == "0/8", "empty occupancy visible")
	session.open_bag()
	check(bag.is_open and bag.panel.visible, "bag opens")
	check(player.input_locked, "bag locks player")
	check(items.process_mode == Node.PROCESS_MODE_DISABLED, "bag gates item input")
	check(
		bag.slot_buttons.all(func(button: Button): return button.disabled), "empty slots disabled"
	)
	session.open_map()
	check(not session.map_ui.is_open, "bag excludes travel map")
	session.close_bag()
	check(not bag.is_open and not player.input_locked, "closing bag restores movement")
	check(items.pickup(), "beer stores directly")
	check(not items.placement_active, "pickup does not start placement")
	check(items.inventory.get_item(0) != null, "beer occupies first slot")
	check(bag.occupancy.text == "1/8", "occupied count refreshes")
	session.open_bag()
	check(not bag.slot_buttons[0].disabled, "occupied slot selectable")
	check(
		bag.slot_buttons[0].icon == items.inventory.get_item(0).definition.icon,
		"slot uses item icon"
	)
	check(bag.slot_buttons[0].tooltip_text == "Birra Dreamscape", "slot has accessible name")
	await capture("bag-open")
	bag.select_slot(0)
	check(not bag.is_open and items.placement_active, "slot selection starts placement")
	check(items.inventory.get_item(0) != null, "selection keeps item committed in slot")
	check(items.world_item == null, "selection does not place through click")
	items.cancel_placement()
	check(items.inventory.get_item(0) != null, "cancel retains exact slot")
	check(items.preview == null, "cancel clears preview")
	items.begin_placement(0)
	session.open_bag()
	check(bag.is_open and not items.placement_active, "opening bag cancels active preview")
	session.close_bag()
	root.content_scale_size = Vector2i(844, 390)
	root.size = Vector2i(844, 390)
	await frames(4)
	session.open_bag()
	var panel_rect: Rect2 = bag.panel.get_global_rect()
	check(panel_rect.position.x >= 0 and panel_rect.end.x <= 844, "compact bag fits horizontally")
	check(panel_rect.position.y >= 0 and panel_rect.end.y <= 390, "compact bag fits vertically")
	check(
		bag.slot_buttons.all(
			func(button: Button): return button.size.x >= 48 and button.size.y >= 48
		),
		"compact touch targets remain at least 48 pixels"
	)
	await capture("bag-compact")
	session.close_bag()
	var touch: Control = session.get_node("Street/TouchHUD/TouchControls")
	touch.enable_touch()
	touch.update_actions()
	check(touch.action_rects.has("bag"), "touch bag action appears when occupied")
	var tap := InputEventScreenTouch.new()
	tap.index = 3
	tap.position = touch.action_rects["bag"].get_center()
	tap.pressed = true
	root.push_input(tap, true)
	Input.flush_buffered_events()
	await frames(2)
	check(bag.is_open and not touch.input_enabled, "touch opens modal bag")
	print("Bag UI: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func travel_to_street() -> void:
	var exit: Area3D = session.active_location.get_node("Exit")
	player.global_position = exit.global_position + Vector3.UP * 0.25
	player.velocity = Vector3.ZERO
	await frames(5)
	session.open_map()
	session.map_ui.select(&"street")
	await session.travel_to(&"street")
	await frames(8)


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless" or "--capture" not in OS.get_cmdline_user_args():
		return
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path("res://../build/verification/bag")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
