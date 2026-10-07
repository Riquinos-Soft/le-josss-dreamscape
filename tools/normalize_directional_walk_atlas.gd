extends SceneTree
## Normalize an eight-row, four-column walk atlas to the runtime sprite scale.

const CELL := 64
const DIRECTIONS := 8
const BODY_HEIGHT := 48
const FOOT_Y := 60


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		push_error("Usage: -- source-4x8.png output-4x8.png")
		quit(1)
		return
	var source := Image.load_from_file(args[0])
	if source == null or source.get_size() != Vector2i(CELL * 4, CELL * DIRECTIONS):
		push_error("Expected a transparent 256x512, four-column/eight-row walk atlas")
		quit(1)
		return
	if source.get_pixel(0, 0).a > 0.01:
		push_error("Expected a transparent walk atlas background")
		quit(1)
		return
	var result := Image.create(CELL * 4, CELL * DIRECTIONS, false, Image.FORMAT_RGBA8)
	for direction in DIRECTIONS:
		var poses: Array[Image] = []
		var common_height := 0
		for pose in 2:
			var frame := source.get_region(Rect2i(pose * CELL, direction * CELL, CELL, CELL))
			var bounds := _alpha_bounds(frame)
			if bounds.size == Vector2i.ZERO:
				push_error("Empty walk pose %d,%d" % [direction, pose])
				quit(1)
				return
			poses.append(frame.get_region(bounds))
			common_height = maxi(common_height, bounds.size.y)
		var scale := float(BODY_HEIGHT) / common_height
		for column in 4:
			var frame := poses[column % 2].duplicate()
			var size := Vector2i(roundi(frame.get_width() * scale), roundi(frame.get_height() * scale))
			if size.x > CELL - 4:
				push_error("Walk frame %d,%d is too wide after normalization" % [direction, column])
				quit(1)
				return
			frame.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
			result.blit_rect(
				frame,
				Rect2i(Vector2i.ZERO, size),
				Vector2i(column * CELL + (CELL - size.x) / 2, direction * CELL + FOOT_Y - size.y)
			)
	if result.save_png(args[1]) != OK:
		push_error("Could not save normalized walk atlas")
		quit(1)
		return
	quit(0)


func _alpha_bounds(image: Image) -> Rect2i:
	var left := image.get_width()
	var top := image.get_height()
	var right := -1
	var bottom := -1
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a >= 0.5:
				left = mini(left, x)
				top = mini(top, y)
				right = maxi(right, x)
				bottom = maxi(bottom, y)
	if right < left or bottom < top:
		return Rect2i()
	return Rect2i(left, top, right - left + 1, bottom - top + 1)
