extends RefCounted
## Shared, immutable prototype data. No catalog is needed for one type.
const TYPE_ID: StringName = &"birra_dreamscape"
const DISPLAY_NAME: String = "Birra Dreamscape"
const SIZE: Vector3 = Vector3(0.12, 0.30, 0.12)
const ICON: Texture2D = preload("res://assets/art/items/birra_dreamscape_icon_v01.png")

var type_id: StringName:
	get:
		return TYPE_ID
var display_name: String:
	get:
		return DISPLAY_NAME
var size: Vector3:
	get:
		return SIZE
var icon: Texture2D:
	get:
		return ICON
