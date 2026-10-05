extends SceneTree
## Offline normalization of generated foliage into four coarse, palette-limited sprites.

const PALETTE := [
	Color("18162e"),
	Color("233346"),
	Color("294b4d"),
	Color("42604f"),
	Color("69734b"),
	Color("a5904f"),
	Color("d5ab60"),
	Color("edd18a"),
	Color("644876"),
	Color("9665b2"),
	Color("c58ac9"),
	Color("a85e7b"),
	Color("d18a96")
]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		push_error("Usage: -- source.png atlas.png")
		quit(1)
		return
	var source := Image.load_from_file(args[0])
	if source == null or source.get_pixel(0, 0).a > 0.01:
		push_error("Expected transparent 2x2 source")
		quit(1)
		return
	for y in source.get_height():
		for x in source.get_width():
			var color := source.get_pixel(x, y)
			color.a = 1.0 if color.a >= 0.5 else 0.0
			source.set_pixel(x, y, color)
	var atlas := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var cell := source.get_size() / 2
	for index in 4:
		var frame := source.get_region(Rect2i(Vector2i(index % 2, index / 2) * cell, cell))
		frame = frame.get_region(frame.get_used_rect())
		var scale := minf(28.0 / frame.get_width(), 24.0 / frame.get_height())
		frame.resize(
			roundi(frame.get_width() * scale),
			roundi(frame.get_height() * scale),
			Image.INTERPOLATE_LANCZOS
		)
		for y in frame.get_height():
			for x in frame.get_width():
				var color := frame.get_pixel(x, y)
				if color.a < 0.5:
					frame.set_pixel(x, y, Color.TRANSPARENT)
					continue
				var nearest := PALETTE[0]
				var distance := INF
				for ink in PALETTE:
					var delta := (
						Vector3(color.r - ink.r, color.g - ink.g, color.b - ink.b).length_squared()
					)
					if delta < distance:
						distance = delta
						nearest = ink
				frame.set_pixel(x, y, nearest)
		atlas.blit_rect(
			frame,
			Rect2i(Vector2i.ZERO, frame.get_size()),
			(
				Vector2i(index % 2, index / 2) * 32
				+ Vector2i((32 - frame.get_width()) / 2, 30 - frame.get_height())
			)
		)
	quit(0 if atlas.save_png(args[1]) == OK else 1)
