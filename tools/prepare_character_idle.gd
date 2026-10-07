extends SceneTree
## Preserve canonical walking identity above the waist while fitting generated standing legs.

const CELL := 64
const WAIST := 43


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 3:
		push_error("Usage: -- normalized-idle.png walk.png output.png")
		quit(1)
		return
	var idle := Image.load_from_file(args[0])
	var walk := Image.load_from_file(args[1])
	if idle == null or walk == null:
		quit(1)
		return
	if idle.get_size() != Vector2i(256, 512) or walk.get_size() != Vector2i(256, 512):
		push_error("Expected normalized 4x8, 64px atlases")
		quit(1)
		return
	var result := Image.create(256, 512, false, Image.FORMAT_RGBA8)
	for direction in 8:
		var upper := walk.get_region(Rect2i(0, direction * CELL, CELL, WAIST))
		var lower := idle.get_region(Rect2i(0, direction * CELL + WAIST, CELL, CELL - WAIST))
		for column in 4:
			result.blit_rect(
				upper, Rect2i(0, 0, CELL, WAIST), Vector2i(column * CELL, direction * CELL)
			)
			result.blit_rect(
				lower,
				Rect2i(0, 0, CELL, CELL - WAIST),
				Vector2i(column * CELL, direction * CELL + WAIST)
			)
	quit(0 if result.save_png(args[2]) == OK else 1)
