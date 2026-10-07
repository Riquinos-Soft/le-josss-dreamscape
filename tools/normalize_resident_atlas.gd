extends SceneTree
## Normalize the generated three-resident strip into three 64px standing cells.

const CELL := 64
const BODY_HEIGHT := 48
const FOOT_Y := 60
const DIRECTIONS := 3


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		push_error("Usage: -- input-3x1.png output-3x1.png")
		quit(1)
		return
	var source := Image.load_from_file(args[0])
	if source == null or source.get_width() < 3 or source.get_height() < 1:
		push_error("Expected a transparent image with a 3x1 grid")
		quit(1)
		return
	var result := Image.create(CELL * DIRECTIONS, CELL, false, Image.FORMAT_RGBA8)
	for direction in DIRECTIONS:
		var source_rect := Rect2i(
			direction * source.get_width() / DIRECTIONS,
			0,
			source.get_width() / DIRECTIONS,
			source.get_height()
		)
		var frame := source.get_region(source_rect)
		var bounds := _alpha_bounds(frame)
		if bounds.size == Vector2i.ZERO:
			push_error("Empty idle direction %d" % direction)
			quit(1)
			return
		frame = frame.get_region(bounds)
		var scale := float(BODY_HEIGHT) / bounds.size.y
		var size := Vector2i(roundi(bounds.size.x * scale), BODY_HEIGHT)
		if size.x > 60:
			push_error("Idle direction %d is too wide" % direction)
			quit(1)
			return
		frame.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
		result.blit_rect(
			frame,
			Rect2i(Vector2i.ZERO, size),
			Vector2i(direction * CELL + (CELL - size.x) / 2, FOOT_Y - size.y)
		)
	if result.save_png(args[1]) != OK:
		push_error("Could not write normalized idle sheet")
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
