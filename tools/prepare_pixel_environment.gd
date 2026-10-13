extends SceneTree
## Normalize the current authored pixel masters; originals and prompts stay offline.


func _initialize() -> void:
	var garden := Image.load_from_file("../assets/source/vegetation/lourizan_botanical.png")
	var regions := [
		Rect2i(0, 0, 660, 690),
		Rect2i(660, 0, 594, 690),
		Rect2i(0, 690, 660, 564),
		Rect2i(660, 690, 594, 564)
	]
	var atlas := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	for index in 4:
		var tree := garden.get_region(regions[index])
		for y in tree.get_height():
			for x in tree.get_width():
				var color := tree.get_pixel(x, y)
				color.a = 1.0 if color.a >= 0.5 else 0.0
				tree.set_pixel(x, y, color)
		tree = tree.get_region(tree.get_used_rect())
		var scale := 120.0 / maxf(tree.get_width(), tree.get_height())
		tree.resize(
			roundi(tree.get_width() * scale),
			roundi(tree.get_height() * scale),
			Image.INTERPOLATE_NEAREST
		)
		var bounds := tree.get_used_rect()
		atlas.blit_rect(
			tree,
			Rect2i(Vector2i.ZERO, tree.get_size()),
			Vector2i(
				(index % 2) * 128 + (128 - tree.get_width()) / 2,
				(index / 2) * 128 + 124 - bounds.end.y
			)
		)
	atlas.save_png("assets/art/vegetation/lourizan_botanical.png")
	var sky := Image.load_from_file("../assets/source/backgrounds/dream_castles.png")
	sky.resize(480, 270, Image.INTERPOLATE_NEAREST)
	sky.save_png("assets/art/backgrounds/dream_castles.png")
	quit()
