extends SceneTree
## Offline normalization of a transparent 2x2 directional source into 64px cells.


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2 or args.size() > 3:
		push_error("Usage: -- source.png output.png [existing_cardinals.png]")
		quit(1)
		return
	var source := Image.load_from_file(args[0])
	if source == null or source.get_width() != source.get_height():
		push_error("Expected a square 2x2 sheet")
		quit(1)
		return
	if source.get_pixel(0, 0).a > 0.01:
		push_error("The generated sheet must have a transparent background")
		quit(1)
		return
	# Remove invisible generation fringe before measuring silhouettes; retain the source file.
	for y in source.get_height():
		for x in source.get_width():
			var color := source.get_pixel(x, y)
			color.a = 1.0 if color.a >= 0.5 else 0.0
			source.set_pixel(x, y, color)
	var append_diagonals := args.size() == 3
	var result := Image.create(256 if append_diagonals else 128, 128, false, Image.FORMAT_RGBA8)
	if append_diagonals:
		var cardinals := Image.load_from_file(args[2])
		if cardinals == null or cardinals.get_size() != Vector2i(128, 128):
			push_error("Expected the existing normalized 128x128 cardinal sheet")
			quit(1)
			return
		for index in 4:
			result.blit_rect(
				cardinals,
				Rect2i((index % 2) * 64, (index / 2) * 64, 64, 64),
				Vector2i(index * 64, 0)
			)
	var cell := source.get_width() / 2
	for index in 4:
		var frame := source.get_region(Rect2i((index % 2) * cell, (index / 2) * cell, cell, cell))
		var bounds := frame.get_used_rect()
		if bounds.size.y == 0:
			push_error("Empty directional sprite")
			quit(1)
			return
		frame = frame.get_region(bounds)
		var width := roundi(float(bounds.size.x) * 48.0 / bounds.size.y)
		frame.resize(width, 48, Image.INTERPOLATE_NEAREST)
		var position := Vector2i((index % 2) * 64 + (64 - width) / 2, (index / 2) * 64 + 12)
		if append_diagonals:
			position = Vector2i(index * 64 + (64 - width) / 2, 76)
		result.blit_rect(frame, Rect2i(0, 0, width, 48), position)
		print("Direction %d: %s -> %dx48; feet pivot 32,60" % [index, bounds, width])
	var error := result.save_png(args[1])
	quit(0 if error == OK else 1)
