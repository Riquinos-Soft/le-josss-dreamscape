extends SceneTree

const Inventory = preload("res://inventory/inventory.gd")
const Item = preload("res://items/item_instance.gd")
const Definition = preload("res://items/item_definition.gd")

var checks := 0
var failures := 0


func _initialize() -> void:
	var bag := Inventory.new()
	var definition := Definition.new()
	var items: Array[Item] = []
	check(bag.first_free_slot() == 0, "first slot starts free")
	check(bag.occupied_count() == 0, "bag starts empty")
	check(not bag.put(null), "null rejected")
	for index in Inventory.CAPACITY:
		var item := Item.new(index + 1, definition)
		items.append(item)
		check(bag.put(item), "item enters first free slot")
		check(bag.get_item(index) == item, "slot keeps exact reference")
	check(bag.occupied_count() == Inventory.CAPACITY, "all eight slots occupied")
	check(bag.first_free_slot() == -1, "full bag has no free slot")
	check(not bag.put(Item.new(99, definition)), "ninth item rejected")
	check(not bag.put(items[0]), "duplicate reference rejected")
	check(bag.take_at(3, items[2]) == null, "wrong expected item cannot remove slot")
	check(bag.get_item(3) == items[3], "failed removal preserves slot")
	check(bag.take_at(-1, items[0]) == null, "negative slot rejected")
	check(bag.take_at(8, items[0]) == null, "out of range slot rejected")
	check(bag.take_at(3, items[3]) == items[3], "expected item removed")
	check(bag.get_item(3) == null, "removal leaves stable hole")
	check(bag.first_free_slot() == 3, "hole becomes first free slot")
	var replacement := Item.new(100, definition)
	check(bag.put(replacement), "replacement fills first hole")
	check(bag.get_item(3) == replacement, "other slot indices stay stable")
	check(bag.get_item(4) == items[4], "later item did not compact")
	print("Bag inventory: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
