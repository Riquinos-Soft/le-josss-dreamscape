extends SceneTree
## Offline native review: all five poses at the contracted camera/pixel scale.

const Catalog = preload("res://v2/characters/appearance_catalog.gd")
var catalog := Catalog.new()
var sprites: Array[AnimatedSprite3D] = []
var keys: Array[String] = []
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
	camera.position = Vector3(0, 0, 60)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.5
	camera.current = true
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("263c45")
	stage.add_child(environment)
	for row in 3:
		var result := catalog.acquire(Catalog.preset(row > 0))
		assert(result.ok)
		keys.append(result.key)
		for phase in 5:
			var sprite := AnimatedSprite3D.new()
			sprite.sprite_frames = result.frames
			sprite.pixel_size = 0.0375
			sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			sprite.position = Vector3((phase - 2) * 2.7, 3.4 - row * 3.4, 0)
			stage.add_child(sprite)
			sprites.append(sprite)
			var label := Label3D.new()
			label.text = (
				["Principal", "Alternativa", "NPC"][row]
				+ (" · quieto" if phase == 0 else " · paso %d" % phase)
			)
			label.font_size = 24
			label.pixel_size = 0.009
			label.position = sprite.position + Vector3.UP * 1.6
			stage.add_child(label)
	for direction in Catalog.DIRECTIONS:
		for i in sprites.size():
			var phase := i % 5
			var sprite := sprites[i]
			sprite.animation = StringName(("idle_" if phase == 0 else "walk_") + direction)
			sprite.frame = 0 if phase == 0 else phase - 1
		await process_frame
		await RenderingServer.frame_post_draw
		var folder := ProjectSettings.globalize_path("res://../build/verification/v2/P2b")
		root.get_texture().get_image().save_png(folder.path_join(direction + ".png"))
	for key in keys:
		catalog.release(key)
	quit()
