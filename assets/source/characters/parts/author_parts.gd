extends SceneTree
## Lossless canonical derivatives; source masks label materials, never body geometry.
const PARTS = [
	"body",
	"skin",
	"face_plain",
	"face_freckles",
	"hair_short_back",
	"hair_short_front",
	"hair_tied_back",
	"hair_tied_front",
	"upper",
	"lower",
	"shoes"
]
var images = {}


func _initialize():
	var mask = Image.load_from_file("assets/source/characters/parts/material_masks.png")
	var materials = ["", "skin", "hair_short_front", "upper", "lower", "shoes"]
	var walk = Image.load_from_file("game/assets/art/characters/joss_walk.png")
	var idle = Image.load_from_file("game/assets/art/characters/joss_idle.png")
	for part in PARTS:
		images[part] = Image.create(320, 512, false, Image.FORMAT_RGBA8)
	var poses := []
	for row in 8:
		for col in 5:
			var cell = (idle if col == 0 else walk).get_region(
				Rect2i(0 if col == 0 else (col - 1) * 64, row * 64, 64, 64)
			)
			var origin = Vector2i(col * 64, row * 64)
			images.body.blit_rect(cell, Rect2i(0, 0, 64, 64), origin)
			for y in 64:
				for x in 64:
					var p = cell.get_pixel(x, y)
					if p.a < 0.5:
						continue
					var part = materials[mask.get_pixelv(origin + Vector2i(x, y)).r8]
					if part != "":
						images[part].set_pixelv(origin + Vector2i(x, y), p)
						if part == "hair_short_front":
							images.hair_tied_front.set_pixelv(origin + Vector2i(x, y), p)
			# Accessories attach to this exact frame's head, never a replacement body.
			var head = cell.get_region(Rect2i(0, 0, 64, 32)).get_used_rect()
			poses.append(
				{
					"row": row,
					"column": col,
					"head": [head.position.x, head.position.y, head.size.x, head.size.y],
					"foot": [32, 60]
				}
			)
			var rear = row in [1, 6, 7]
			var tail_x = head.position.x + 1 if row in [3, 5, 7] else head.end.x - 4
			var tail_y = head.position.y + 12
			var colors = [Color("2e1c19"), Color("603021"), Color("91452b"), Color("b96a40")]
			for y in 11:
				for x in 5:
					var shift = int(y / 4.0)
					if (y == 0 or y == 10) and (x == 0 or x == 4):
						continue
					var shade = (
						0
						if x == 0 or x == 4 or y == 10
						else (3 if x == 2 else (2 if x == 1 else 1))
					)
					images.hair_tied_back.set_pixelv(
						origin + Vector2i(tail_x + x + shift, tail_y + y), colors[shade]
					)
			if not rear:
				var center = int(head.get_center().x)
				var cheek_y = head.position.y + 17
				for offset in [Vector2i(-4, 0), Vector2i(-2, 1), Vector2i(4, 0), Vector2i(6, 1)]:
					var at = origin + Vector2i(center, cheek_y) + offset
					if images.skin.get_pixelv(at).a > 0.5:
						images.face_freckles.set_pixelv(at, Color("a36549"))
	var directory = "game/v2/characters/parts"
	DirAccess.make_dir_recursive_absolute(directory)
	for part in PARTS:
		images[part].save_png(directory.path_join(part + ".png"))
	var metadata := FileAccess.open(directory.path_join("poses.json"), FileAccess.WRITE)
	metadata.store_string(
		(
			JSON.stringify(
				{"version": 1, "source": "canonical_joss", "cell": 64, "poses": poses}, "\t"
			)
			+ "\n"
		)
	)
	quit()
