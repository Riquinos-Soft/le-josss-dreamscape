extends Node3D
## Painted local light source consumed by the pixel color pass.

var place_id: StringName = &"lourizan"
var indoors := false
var radius := 3.4
var bulb_height := 2.35
var fixture := true


func _ready() -> void:
	add_to_group("pixel_lights")
	if not fixture:
		return
	var sprite := Sprite3D.new()
	sprite.texture = preload("res://assets/art/architecture/lantern.svg")
	sprite.pixel_size = 0.05
	sprite.position.y = 1.6
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	add_child(sprite)
