extends SceneTree
## Offline import derivative: fixed generated atlas → nearest-sampled 64px cells.


func _initialize() -> void:
	var source := Image.load_from_file("assets/source/characters/chicken.png")
	if source == null:
		quit(1)
		return
	for y in source.get_height():
		for x in source.get_width():
			var color := source.get_pixel(x, y)
			color.a = 1.0 if color.a >= 0.5 else 0.0
			source.set_pixel(x, y, color)
	var result := Image.create(192, 256, false, Image.FORMAT_RGBA8)
	var row_edges := [0.0, 0.235, 0.474, 0.729, 1.0]
	for row in 4:
		var cells: Array[Image] = []
		var extent := 0
		for column in 3:
			var top := roundi(row_edges[row] * source.get_height())
			var bottom := roundi(row_edges[row + 1] * source.get_height())
			var left := roundi(column * source.get_width() / 3.0)
			var right := roundi((column + 1) * source.get_width() / 3.0)
			var cell := source.get_region(Rect2i(left, top, right - left, bottom - top))
			cell = main_body_band(cell)
			var bounds := cell.get_used_rect()
			if bounds.size == Vector2i.ZERO:
				quit(1)
				return
			cells.append(cell.get_region(bounds))
			extent = maxi(extent, maxi(bounds.size.x, bounds.size.y))
		var scale := 56.0 / extent
		for column in 3:
			var cell := cells[column]
			cell.resize(
				roundi(cell.get_width() * scale),
				roundi(cell.get_height() * scale),
				Image.INTERPOLATE_NEAREST
			)
			var bounds := cell.get_used_rect()
			result.blit_rect(
				cell,
				Rect2i(Vector2i.ZERO, cell.get_size()),
				Vector2i(column * 64 + (64 - cell.get_width()) / 2, row * 64 + 60 - bounds.end.y)
			)
	quit(0 if result.save_png("game/assets/art/characters/chicken.png") == OK else 1)


func main_body_band(frame: Image) -> Image:
	var best_start := 0
	var best_height := 0
	var start := -1
	for y in range(frame.get_height() + 1):
		var occupied := false
		if y < frame.get_height():
			for x in frame.get_width():
				if frame.get_pixel(x, y).a >= 0.5:
					occupied = true
					break
		if occupied and start < 0:
			start = y
		if not occupied and start >= 0:
			if y - start > best_height:
				best_start = start
				best_height = y - start
			start = -1
	return frame.get_region(Rect2i(0, best_start, frame.get_width(), best_height))
