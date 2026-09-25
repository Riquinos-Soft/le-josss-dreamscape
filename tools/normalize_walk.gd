extends SceneTree
## Offline grid normalization: one scale per direction, never per-frame stretching.


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		push_error("Usage: -- source.png output.png (4 columns, 8 rows)")
		quit(1)
		return
	var source := Image.load_from_file(args[0])
	if source == null or source.get_pixel(0, 0).a > 0.01:
		push_error("Expected a transparent walk sheet")
		quit(1)
		return
	for y in source.get_height():
		for x in source.get_width():
			var color := source.get_pixel(x, y)
			color.a = 1.0 if color.a >= 0.5 else 0.0
			source.set_pixel(x, y, color)
	var result := Image.create(256, 512, false, Image.FORMAT_RGBA8)
	for row in 8:
		var frames: Array[Image] = []
		var max_height := 0
		for column in 4:
			var left := roundi(column * source.get_width() / 4.0)
			var top := roundi(row * source.get_height() / 8.0)
			var right := roundi((column + 1) * source.get_width() / 4.0)
			var bottom := roundi((row + 1) * source.get_height() / 8.0)
			var frame := source.get_region(Rect2i(left, top, right - left, bottom - top))
			var bounds := frame.get_used_rect()
			if bounds.size.y == 0:
				push_error("Empty walk frame %d,%d" % [row, column])
				quit(1)
				return
			max_height = maxi(max_height, bounds.size.y)
			frames.append(frame.get_region(bounds))
		var scale := 48.0 / max_height
		for column in 4:
			var frame := frames[column]
			var width := roundi(frame.get_width() * scale)
			var height := roundi(frame.get_height() * scale)
			if width > 60:
				push_error("Walk frame too wide for the existing sprite contract")
				quit(1)
				return
			frame.resize(width, height, Image.INTERPOLATE_NEAREST)
			# Nearest downsampling can remove a one-pixel source fringe at the sole.
			# Anchor the actual surviving opaque pixels, without changing the row scale.
			var normalized_bounds := frame.get_used_rect()
			result.blit_rect(
				frame,
				Rect2i(0, 0, width, height),
				Vector2i(column * 64 + (64 - width) / 2, row * 64 + 60 - normalized_bounds.end.y)
			)
		print("Walk row %d: common scale %.4f, feet at 60" % [row, scale])
	quit(0 if result.save_png(args[1]) == OK else 1)
