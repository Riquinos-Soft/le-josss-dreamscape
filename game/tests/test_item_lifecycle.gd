extends SceneTree
const Inventory = preload("res://inventory/inventory.gd")
const Item = preload("res://items/item_instance.gd")
const Definition = preload("res://items/item_definition.gd")
var checks := 0
var failures := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var courtyard = load("res://world/courtyard.tscn").instantiate()
	root.add_child(courtyard)
	current_scene = courtyard
	await frames(10)
	var loop = courtyard.get_node("ItemLoop")
	loop.set_physics_process(false) # Deterministic target instead of a real mouse.
	var player = courtyard.get_node("Player")
	var original = loop.world_item.item
	var identity: int = original.session_id
	var definition = original.definition
	check(loop.inventory.item == null, "starts empty")
	var slot := Inventory.new()
	check(slot.put(original), "slot accepts instance")
	check(not slot.put(Item.new(2, definition)), "occupied slot rejects another instance")
	check(slot.take(Item.new(3, definition)) == null and slot.item == original, "wrong removal leaves slot unchanged")
	check(slot.take(original) == original and slot.item == null, "expected removal preserves reference")
	for cycle in 3:
		check(loop.pickup(), "pickup succeeds")
		check(loop.inventory.item == original and loop.world_item == null, "pickup moves same reference")
		check(not loop.pickup(), "repeat pickup rejected")
		check(loop.begin_placement(), "begin placement")
		check(not loop.begin_placement(), "repeat begin rejected")
		check(loop.inventory.item == original and loop.preview is MeshInstance3D, "preview leaves ownership in inventory")
		loop.cancel_placement()
		check(loop.inventory.item == original and loop.preview == null and loop.world_item == null, "cancel conserves instance")
		loop.begin_placement()
		loop.target = Vector3(100, 0.25, 100)
		check(not loop.confirm_placement(), "out of reach rejected")
		check(loop.inventory.item == original and loop.world_item == null and loop.placement_active, "invalid confirm conserves instance")
		loop.target = Vector3(player.position.x, 0.25, player.position.z)
		check(not loop.confirm_placement(), "player overlap rejected")
		loop.target = Vector3(0, 0.25, 1.5)
		loop.rotate_preview(cycle + 1)
		var expected_yaw: float = loop.yaw
		check(loop.confirm_placement(), "valid confirm succeeds")
		check(loop.inventory.item == null and loop.world_item.item == original, "placement transfers same reference")
		check(loop.world_item.item.session_id == identity and loop.world_item.item.definition == definition, "ID and definition survive")
		check(loop.world_item.position.is_equal_approx(Vector3(0, 0.25, 1.5)), "confirmed position matches")
		check(loop.world_item.basis.is_equal_approx(Basis(Vector3.UP, expected_yaw)), "confirmed rotation matches")
		check(not loop.confirm_placement(), "repeat confirm rejected")
		var count := 0
		for child in courtyard.get_children():
			if child is StaticBody3D and child.get_script() == load("res://items/world_item.gd"):
				count += 1
		check(count == 1, "exactly one committed world representation")
		await frames(3)
	# Test our range/obstruction/footprint policy against the actual courtyard.
	player.position = Vector3(0, 0, 6)
	await frames(3)
	check(not loop.pickup() and loop.world_item.item == original, "distant pickup unchanged")
	player.position = Vector3(-3, 0, -0.6)
	loop.world_item.position = Vector3(-3, 0.25, -2.2)
	await frames(3)
	check(not loop.pickup(), "obstacle blocks pickup")
	check(not loop.valid_pose(Vector3(-3, 0.25, -1.1), 0), "obstacle overlap rejected")
	player.position = Vector3(9, 0, 4)
	await frames(3)
	check(not loop.valid_pose(Vector3(9.8, 0.25, 4), 0), "wall/edge overlap rejected")
	check(not loop.valid_pose(Vector3(9, 1.25, 3), 0), "midair rejected")
	print("Item lifecycle: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
