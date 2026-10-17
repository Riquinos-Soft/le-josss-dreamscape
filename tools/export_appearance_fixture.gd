extends SceneTree
## Export actual Godot inputs/results for the HTML compositor parity check.

const Catalog = preload("res://v2/characters/appearance_catalog.gd")


func _initialize() -> void:
	var folder := ProjectSettings.globalize_path("res://../build/verification/appearance-parity")
	DirAccess.make_dir_recursive_absolute(folder)
	var catalog := Catalog.new()
	var manifest := {"parts": [], "cases": []}
	for part in catalog.textures:
		manifest.parts.append(part)
		write_bytes(folder.path_join(part + ".rgba"), catalog.textures[part].get_image().get_data())
	var blond := Catalog.preset()
	blond.hair_palette = "blond"
	blond.upper_palette = "navy"
	blond.skin_palette = "olive"
	for config in [Catalog.preset(), Catalog.preset(true), blond]:
		var result: Dictionary = catalog.compose(config)
		assert(result.ok)
		var index: int = manifest.cases.size()
		manifest.cases.append(config)
		for row in 8:
			for column in 5:
				var animation: String = (
					("idle_" if column == 0 else "walk_") + Catalog.DIRECTIONS[row]
				)
				var frame := 0 if column == 0 else column - 1
				var image: Image = result.frames.get_frame_texture(animation, frame).get_image()
				write_bytes(
					folder.path_join("%d-%d-%d.rgba" % [index, row, column]), image.get_data()
				)
	var file := FileAccess.open(folder.path_join("manifest.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest))
	print("Appearance parity fixtures: ", folder)
	quit()


func write_bytes(path: String, data: PackedByteArray) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(data)
