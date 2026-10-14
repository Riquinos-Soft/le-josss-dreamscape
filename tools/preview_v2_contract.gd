extends SceneTree
## P1 visual calibration only. Does not change the shipped entry point or assets.

var stage: Node3D


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	root.size = Vector2i(1280, 720)
	stage = Node3D.new()
	root.add_child(stage)
	current_scene = stage
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.position = Vector3(9, 12, 12).normalized() * 60 + Vector3.UP * 0.9
	camera.look_at(Vector3.UP * 0.9)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.5
	camera.far = 200
	camera.current = true
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("263c45")
	stage.add_child(environment)
	box(Vector3(0, -0.15, 0), Vector3(9.6, 0.3, 7.2), Color("6d7861"))
	# One sample of intentional color clusters at the human sprite's texel scale.
	var tile := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	tile.fill(Color("a6a38b"))
	tile.fill_rect(Rect2i(0, 0, 32, 1), Color("6b7164"))
	tile.fill_rect(Rect2i(0, 0, 1, 32), Color("6b7164"))
	tile.fill_rect(Rect2i(2, 2, 27, 1), Color("c0b99b"))
	tile.fill_rect(Rect2i(22, 26, 7, 3), Color("999c82"))
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(9.6, 7.2)
	var floor_material := StandardMaterial3D.new()
	floor_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	floor_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	floor_material.albedo_texture = ImageTexture.create_from_image(tile)
	floor_material.uv1_scale = Vector3(8, 6, 1)
	var floor_visual := MeshInstance3D.new()
	floor_visual.mesh = floor_mesh
	floor_visual.material_override = floor_material
	stage.add_child(floor_visual)
	box(Vector3(-2.1, 1.2, -2.5), Vector3(3, 2.4, 0.3), Color("8d907b"))
	box(Vector3(2.1, 1.2, -2.5), Vector3(3, 2.4, 0.3), Color("8d907b"))
	box(Vector3(0, 2.55, -2.5), Vector3(7.2, 0.3, 0.3), Color("c0b99b"))
	for x in [-2.4, 2.4]:
		var ornament := Sprite3D.new()
		ornament.texture = load("res://assets/art/architecture/lourizan-window.svg")
		ornament.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		ornament.pixel_size = 0.0375
		ornament.position = Vector3(x, 1.3, -2.32)
		stage.add_child(ornament)
	var names := ["Joss idle", "Joss walk", "Lucas idle", "Lucas walk"]
	for i in 4:
		var character := AnimatedSprite3D.new()
		character.sprite_frames = load(
			"res://assets/art/characters/%s.tres" % ("joss" if i < 2 else "lucas")
		)
		character.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		character.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		character.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		character.pixel_size = 0.0375
		character.position = Vector3(-2.7 + i * 1.8, 1.05, 0)
		stage.add_child(character)
		character.play(&"idle_down" if i % 2 == 0 else &"walk_down")
		var label := Label3D.new()
		label.text = names[i]
		label.position = character.position + Vector3.UP * 1.6
		label.font_size = 28
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		stage.add_child(label)
	await create_timer(0.7).timeout
	await capture("desktop")
	root.size = Vector2i(844, 390)
	await create_timer(0.5).timeout
	await capture("compact")
	quit()


func box(at: Vector3, dimensions: Vector3, color: Color) -> void:
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	visual.material_override = material
	visual.position = at
	stage.add_child(visual)


func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path("res://../build/verification/v2/P1")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))
