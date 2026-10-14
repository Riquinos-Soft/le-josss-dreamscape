extends SceneTree
## Editable pixel master. Original shapes are rasterized on the shared 64px grid.
## Run from repository root: Godot --headless --script this/file.gd.

const DIRECTIONS := [
	"down", "up", "left", "right", "down_left", "down_right", "up_left", "up_right"
]
const PARTS := [
	"body",
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
const SHADES := [Color("211e25"), Color("555555"), Color("aaaaaaaa"), Color("ffffff")]
var cell: Image


func _initialize() -> void:
	var atlases := {}
	for part in PARTS:
		atlases[part] = Image.create(320, 512, false, Image.FORMAT_RGBA8)
	var poses := {}
	for row in 8:
		var direction: String = DIRECTIONS[row]
		var anchors: Array = []
		for phase in 5:
			var bob := -1 if phase in [2, 4] else 0
			var stride: int = [0, -2, 0, 2, 0][phase]
			anchors.append(
				{
					"head":
					[
						(
							32
							+ (
								-2
								if direction.ends_with("left")
								else (2 if direction.ends_with("right") else 0)
							)
						),
						25 + bob
					],
					"neck": [32, 35 + bob],
					"pelvis": [32, 46 + bob],
					"foot": [32, 60]
				}
			)
			for part in PARTS:
				cell = Image.create(64, 64, false, Image.FORMAT_RGBA8)
				draw_part(part, direction, bob, stride)
				atlases[part].blit_rect(cell, Rect2i(0, 0, 64, 64), Vector2i(phase * 64, row * 64))
		poses[direction] = anchors
	var directory := "game/v2/characters/parts"
	DirAccess.make_dir_recursive_absolute(directory)
	for part in PARTS:
		if atlases[part].save_png(directory.path_join(part + ".png")) != OK:
			quit(1)
			return
	var data := {
		"version": 1,
		"cell": 64,
		"columns": ["idle", "walk0", "walk1", "walk2", "walk3"],
		"directions": DIRECTIONS,
		"poses": poses
	}
	var output := FileAccess.open(directory.path_join("poses.json"), FileAccess.WRITE)
	output.store_string(JSON.stringify(data, "\t") + "\n")
	quit()


func draw_part(part: String, direction: String, bob: int, stride: int) -> void:
	var rear := direction.begins_with("up")
	var side := -1 if direction.ends_with("left") else (1 if direction.ends_with("right") else 0)
	var profile := direction in ["left", "right"]
	var hx := 32 + side * 2
	var hy := 25 + bob
	var left_foot := 59 - maxi(stride, 0)
	var right_foot := 59 + mini(stride, 0)
	var arm := stride / 2
	var left_x := 26 + (stride * side if profile else 0)
	var right_x := 33 - (stride * side if profile else 0)
	match part:
		"body":
			# The same head silhouette is translated, never resized between phases.
			poly(
				[
					Vector2i(hx - 7, hy - 10),
					Vector2i(hx + 6, hy - 10),
					Vector2i(hx + 10, hy - 5),
					Vector2i(hx + 9, hy + 4),
					Vector2i(hx + 5, hy + 9),
					Vector2i(hx - 5, hy + 9),
					Vector2i(hx - 10, hy + 3),
					Vector2i(hx - 10, hy - 5)
				],
				0
			)
			poly(
				[
					Vector2i(hx - 6, hy - 8),
					Vector2i(hx + 5, hy - 8),
					Vector2i(hx + 8, hy - 4),
					Vector2i(hx + 7, hy + 3),
					Vector2i(hx + 4, hy + 7),
					Vector2i(hx - 4, hy + 7),
					Vector2i(hx - 8, hy + 2),
					Vector2i(hx - 8, hy - 4)
				],
				2
			)
			if profile:
				rect(hx + (8 if side > 0 else -11), hy + 1, 3, 3, 0)
				rect(hx + (8 if side > 0 else -10), hy + 1, 2, 2, 2)
			rect(hx - 7, hy - 3, 3, 7, 1)
			rect(hx - 2, hy - 6, 6, 4, 3)
			rect(29, 32 + bob, 6, 6, 0)
			rect(30, 33 + bob, 4, 4, 2)
			rect(21, 41 + bob + arm, 5, 7, 0)
			rect(22, 42 + bob + arm, 3, 5, 2)
			rect(38, 41 + bob - arm, 5, 7, 0)
			rect(39, 42 + bob - arm, 3, 5, 2)
		"face_plain", "face_freckles":
			if rear:
				return
			if not profile:
				rect(hx - 5, hy, 3, 3, 0)
				rect(hx - 4, hy, 1, 1, 3)
				rect(hx + 3, hy, 3, 3, 0)
				rect(hx + 4, hy, 1, 1, 3)
			else:
				rect(hx + side * 4, hy, 2, 3, 0)
				rect(hx + side * 4, hy, 1, 1, 3)
			rect(hx + side, hy + 3, 2, 2, 1)
			rect(hx - 2 + side * 2, hy + 6, 4, 1, 0)
			if part == "face_freckles":
				# Asymmetric cheek detail is authored per direction, not mirrored.
				if direction != "left":
					rect(hx + 4, hy + 4, 1, 1, 1)
					rect(hx + 6, hy + 5, 1, 1, 1)
		"hair_short_back", "hair_tied_back":
			if part == "hair_tied_back":
				rect(hx - 10 - side * 2, hy + 1, 7, 15, 0)
				rect(hx - 9 - side * 2, hy + 2, 5, 13, 1)
				rect(hx - 8 - side * 2, hy + 3, 2, 10, 2)
			else:
				rect(hx - 10, hy - 5, 20, 10, 0)
		"hair_short_front", "hair_tied_front":
			poly(
				[
					Vector2i(hx - 11, hy - 5),
					Vector2i(hx - 8, hy - 10),
					Vector2i(hx - 3, hy - 12),
					Vector2i(hx + 6, hy - 10),
					Vector2i(hx + 10, hy - 6),
					Vector2i(hx + 8, hy - 2),
					Vector2i(hx + 2, hy - 4),
					Vector2i(hx - 4, hy - 2),
					Vector2i(hx - 9, hy + 1)
				],
				0
			)
			rect(hx - 7, hy - 8, 12, 4, 2)
			rect(hx - 5, hy - 9, 5, 2, 3)
			rect(hx + 1, hy - 5, 6, 2, 1)
			rect(hx - 9, hy - 4, 3, 5, 1)
			if rear:
				rect(hx - 8, hy - 3, 16, 9, 1)
				rect(hx - 5, hy - 2, 10, 7, 2)
				rect(hx - 3, hy + 5, 7, 3, 1)
			if part == "hair_tied_front":
				rect(hx + 5, hy - 7, 3, 5, 3)
		"upper":
			if profile:
				rect(26, 35 + bob, 13, 13, 0)
				rect(27, 37 + bob, 10, 10, 2)
				rect(27, 37 + bob, 3, 8, 3)
				rect(35, 38 + bob, 3, 8, 1)
				rect(29, 37 + bob + arm, 6, 10, 0)
				rect(30, 38 + bob + arm, 4, 8, 2)
				return
			poly(
				[
					Vector2i(27, 35 + bob),
					Vector2i(37, 35 + bob),
					Vector2i(42, 39 + bob),
					Vector2i(40, 45 + bob),
					Vector2i(37, 44 + bob),
					Vector2i(37, 47 + bob),
					Vector2i(26, 47 + bob),
					Vector2i(26, 44 + bob),
					Vector2i(23, 45 + bob),
					Vector2i(21, 39 + bob)
				],
				0
			)
			rect(27, 37 + bob, 10, 9, 2)
			rect(28, 37 + bob, 3, 7, 3)
			rect(34, 38 + bob, 3, 8, 1)
			rect(23, 39 + bob, 4, 3, 2)
			rect(37, 39 + bob, 4, 3, 1)
			if not rear:
				rect(30, 35 + bob, 4, 2, 0)
				rect(31, 37 + bob, 1, 8, 1)
		"lower":
			rect(26, 45 + bob, 12, 4, 0)
			rect(27, 46 + bob, 10, 2, 1)
			rect(left_x, 48 + bob, 6, left_foot - 47 - bob, 0)
			rect(right_x, 48 + bob, 6, right_foot - 47 - bob, 0)
			rect(left_x + 1, 48 + bob, 4, left_foot - 49 - bob, 2)
			rect(right_x + 1, 48 + bob, 4, right_foot - 49 - bob, 1)
			rect(left_x + 1, 48 + bob, 1, 6, 3)
		"shoes":
			rect(left_x - 1, left_foot - 3, 7, 4, 0)
			rect(right_x, right_foot - 3, 7, 4, 0)
			rect(left_x, left_foot - 2, 5, 2, 2)
			rect(right_x + 1, right_foot - 2, 5, 2, 2)
			rect(left_x, left_foot, 5, 1, 3)
			rect(right_x + 1, right_foot, 5, 1, 3)


func rect(x: int, y: int, width: int, height: int, shade: int) -> void:
	cell.fill_rect(Rect2i(x, y, width, height), SHADES[shade])


func poly(points: Array, shade: int) -> void:
	# Integer scan conversion keeps exact, opaque clusters without antialiasing.
	for y in 64:
		for x in 64:
			var inside := false
			var previous := points.size() - 1
			for i in points.size():
				var a: Vector2i = points[i]
				var b: Vector2i = points[previous]
				if (a.y > y) != (b.y > y):
					var edge := float(b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x
					if x < edge:
						inside = not inside
				previous = i
			if inside:
				cell.set_pixel(x, y, SHADES[shade])
