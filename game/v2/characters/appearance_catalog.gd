extends RefCounted
## Catalog IDs only. Compositions live while presenters hold them, never per frame.

const DIRECTIONS := [
	"down", "up", "left", "right", "down_left", "down_right", "up_left", "up_right"
]
const FIELDS := [
	"version",
	"body",
	"face",
	"hair",
	"upper",
	"lower",
	"shoes",
	"skin_palette",
	"hair_palette",
	"upper_palette",
	"lower_palette",
	"shoe_palette"
]
const OPTIONS := {
	"body": ["human_v1"],
	"face": ["plain", "freckles"],
	"hair": ["short", "tied"],
	"upper": ["shirt"],
	"lower": ["trousers"],
	"shoes": ["boots"],
	"skin_palette": ["warm", "olive", "deep"],
	"hair_palette": ["chestnut", "ink", "blond"],
	"upper_palette": ["teal", "ochre", "navy"],
	"lower_palette": ["charcoal", "earth"],
	"shoe_palette": ["leather"]
}
var palette_data: Dictionary = JSON.parse_string(
	FileAccess.get_file_as_string("res://v2/characters/parts/palettes.json")
)
var textures := {
	"skin": preload("res://v2/characters/parts/skin.png"),
	"body": preload("res://v2/characters/parts/body.png"),
	"face_plain": preload("res://v2/characters/parts/face_plain.png"),
	"face_freckles": preload("res://v2/characters/parts/face_freckles.png"),
	"hair_short_back": preload("res://v2/characters/parts/hair_short_back.png"),
	"hair_short_front": preload("res://v2/characters/parts/hair_short_front.png"),
	"hair_tied_back": preload("res://v2/characters/parts/hair_tied_back.png"),
	"hair_tied_front": preload("res://v2/characters/parts/hair_tied_front.png"),
	"upper": preload("res://v2/characters/parts/upper.png"),
	"lower": preload("res://v2/characters/parts/lower.png"),
	"shoes": preload("res://v2/characters/parts/shoes.png")
}
var cache := {}


static func preset(alternate: bool = false) -> Dictionary:
	return {
		"version": 1,
		"body": "human_v1",
		"face": "freckles" if alternate else "plain",
		"hair": "tied" if alternate else "short",
		"upper": "shirt",
		"lower": "trousers",
		"shoes": "boots",
		"skin_palette": "deep" if alternate else "warm",
		"hair_palette": "ink" if alternate else "chestnut",
		"upper_palette": "ochre" if alternate else "teal",
		"lower_palette": "earth" if alternate else "charcoal",
		"shoe_palette": "leather"
	}


static func validate(config: Dictionary) -> String:
	if not config.has("version") or typeof(config.version) != TYPE_INT or config.version != 1:
		return "unsupported_version"
	if config.size() != FIELDS.size():
		return "invalid_fields"
	for field in FIELDS:
		if not config.has(field):
			return "missing_" + field
		if field != "version":
			if typeof(config[field]) != TYPE_STRING or config[field] not in OPTIONS[field]:
				return "unknown_" + field
	return ""


func acquire(config: Dictionary) -> Dictionary:
	var error := validate(config)
	if error != "":
		return {"ok": false, "error": error}
	var values: Array = []
	for field in FIELDS:
		values.append(config[field])
	var key := JSON.stringify(values)
	if not cache.has(key):
		var result := compose(config)
		if not result.ok:
			return result
		cache[key] = {"frames": result.frames, "users": 0, "warnings": result.warnings}
	cache[key].users += 1
	return {
		"ok": true,
		"key": key,
		"frames": cache[key].frames,
		"warnings": cache[key].warnings.duplicate()
	}


func release(key: String) -> void:
	if cache.has(key):
		cache[key].users -= 1
		if cache[key].users <= 0:
			cache.erase(key)


func compose(config: Dictionary) -> Dictionary:
	var warnings: Array[String] = []
	var face: String = "face_" + config.face
	var hair: String = "hair_" + config.hair
	if not textures.has(face):
		warnings.append("unavailable_face:" + config.face)
		face = "face_plain"
	if not textures.has(hair + "_back") or not textures.has(hair + "_front"):
		warnings.append("unavailable_hair:" + config.hair)
		hair = "hair_short"
	var palettes := {
		"body": config.skin_palette,
		"skin": config.skin_palette,
		face: config.skin_palette,
		hair + "_back": config.hair_palette,
		hair + "_front": config.hair_palette,
		"upper": config.upper_palette,
		"lower": config.lower_palette,
		"shoes": config.shoe_palette
	}
	var images := {}
	for part in palettes:
		if not textures.has(part) or textures[part] == null:
			return {"ok": false, "error": "missing_required_part:" + part}
		var source: Image = textures[part].get_image()
		if source.get_size() != Vector2i(320, 512):
			return {"ok": false, "error": "invalid_part_size:" + part}
		images[part] = colorize(source, palettes[part], part)
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for row in 8:
		# Rear hair falls over the shirt when viewed from behind.
		var order := [
			hair + "_back", "body", "skin", "lower", "shoes", "upper", face, hair + "_front"
		]
		if DIRECTIONS[row].begins_with("up"):
			order = [
				"body", "skin", "lower", "shoes", "upper", hair + "_back", face, hair + "_front"
			]
		for walking in [false, true]:
			var name := StringName(("walk_" if walking else "idle_") + DIRECTIONS[row])
			frames.add_animation(name)
			frames.set_animation_speed(name, 8.0)
			frames.set_animation_loop(name, true)
			for phase in 4 if walking else 1:
				var column: int = phase + 1 if walking else 0
				var image: Image = images.body.get_region(Rect2i(column * 64, row * 64, 64, 64))
				for part in order:
					if part == "body":
						continue
					var region := Rect2i(column * 64, row * 64, 64, 64)
					if part == hair + "_back" and not DIRECTIONS[row].begins_with("up"):
						for y in 64:
							for x in 64:
								var pixel: Color = images[part].get_pixel(
									region.position.x + x, region.position.y + y
								)
								if image.get_pixel(x, y).a == 0 and pixel.a > 0:
									image.set_pixel(x, y, pixel)
					else:
						image.blit_rect_mask(images[part], images[part], region, Vector2i.ZERO)

				frames.add_frame(name, ImageTexture.create_from_image(image))
	return {"ok": true, "frames": frames, "warnings": warnings}


func colorize(source: Image, palette: String, part: String) -> Image:
	# Default material colors are a byte-for-byte no-op on the canonical art.
	var image := source.duplicate() as Image
	if part == "body" or palette == palette_data.defaults[part]:
		return image
	var target: Array = palette_data.colors[palette]
	var anchor := int(palette_data.luminance[part])
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			if pixel.a8 == 0:
				continue
			var light := 54 * pixel.r8 + 183 * pixel.g8 + 19 * pixel.b8
			image.set_pixel(
				x,
				y,
				Color8(
					mini(255, int(light * int(target[0]) / (256.0 * anchor))),
					mini(255, int(light * int(target[1]) / (256.0 * anchor))),
					mini(255, int(light * int(target[2]) / (256.0 * anchor))),
					pixel.a8
				)
			)
	return image
