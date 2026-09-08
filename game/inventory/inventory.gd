extends RefCounted
## One slot. Only explicit, expected-instance transfers may remove its contents.
const Item = preload("res://items/item_instance.gd")
var _item: Item
var item: Item:
	get: return _item


func put(value: Item) -> bool:
	if value == null or _item != null:
		return false
	_item = value
	return true


func take(expected: Item) -> Item:
	if expected == null or _item != expected:
		return null
	var result := _item
	_item = null
	return result
