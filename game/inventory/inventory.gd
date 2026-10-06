extends RefCounted
## Eight stable slots. Only explicit, expected-instance transfers may remove contents.

signal changed

const Item = preload("res://items/item_instance.gd")
const CAPACITY := 8

var _slots: Array[Item] = []


func _init() -> void:
	_slots.resize(CAPACITY)
	_slots.fill(null)


func get_item(index: int) -> Item:
	if index < 0 or index >= CAPACITY:
		return null
	return _slots[index]


func first_free_slot() -> int:
	for index in CAPACITY:
		if _slots[index] == null:
			return index
	return -1


func find_item(value: Item) -> int:
	if value == null:
		return -1
	for index in CAPACITY:
		if _slots[index] == value:
			return index
	return -1


func occupied_count() -> int:
	return CAPACITY - _slots.count(null)


func put(value: Item) -> bool:
	if value == null or find_item(value) != -1:
		return false
	var index := first_free_slot()
	if index == -1:
		return false
	_slots[index] = value
	changed.emit()
	return true


func take_at(index: int, expected: Item) -> Item:
	if index < 0 or index >= CAPACITY or expected == null or _slots[index] != expected:
		return null
	var result := _slots[index]
	_slots[index] = null
	changed.emit()
	return result
