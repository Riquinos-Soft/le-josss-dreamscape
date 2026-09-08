extends RefCounted

const Definition = preload("res://items/item_definition.gd")
var _session_id: int
var _definition: Definition
var session_id: int:
	get: return _session_id
var definition: Definition:
	get: return _definition


func _init(id: int, type: Definition) -> void:
	_session_id = id
	_definition = type
