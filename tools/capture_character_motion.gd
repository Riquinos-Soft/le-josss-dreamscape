extends SceneTree
## Run real animation clocks beside the unchanged original at gameplay scale.

const Catalog = preload("res://v2/characters/appearance_catalog.gd")
const Direction = preload("res://player/directional_animation.gd")
var checks := 0
var failures := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	root.size = Vector2i(1280, 720)
	var stage := Node3D.new()
	root.add_child(stage)
	current_scene = stage
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.5
	camera.position.z = 20
	stage.add_child(camera)
	var catalog := Catalog.new()
	var restored: Dictionary = catalog.acquire(Catalog.preset())
	var alternate: Dictionary = catalog.acquire(Catalog.preset(true))
	var sprites: Array[AnimatedSprite3D] = []
	var frames: Array[SpriteFrames] = [
		load("res://assets/art/characters/joss.tres"), restored.frames, alternate.frames
	]
	for index in 3:
		var sprite := AnimatedSprite3D.new()
		sprite.sprite_frames = frames[index]
		sprite.pixel_size = 0.0375
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		sprite.position.x = (index - 1) * 4.0
		stage.add_child(sprite)
		sprites.append(sprite)
		var label := Label3D.new()
		label.text = ["Joss original", "Restaurado", "Personalizado"][index]
		label.position = sprite.position + Vector3.UP * 1.7
		label.pixel_size = 0.01
		stage.add_child(label)
	for direction in Catalog.DIRECTIONS:
		var previous_frame := sprites[1].frame
		var previous_progress := sprites[1].frame_progress
		var turning := String(sprites[1].animation).begins_with("walk_")
		for sprite in sprites:
			Direction.play_direction(sprite, direction, true)
		if turning:
			verify(sprites[1].frame == previous_frame, "turn preserves footstep phase")
			verify(
				is_equal_approx(sprites[1].frame_progress, previous_progress),
				"turn preserves progress"
			)
		for tick in 45:
			await process_frame
			verify(sprites[0].frame == sprites[1].frame, "original and restored clocks agree")
			if tick == 20:
				await capture(direction + "-walk")
		for sprite in sprites:
			Direction.play_direction(sprite, direction, false)
		verify(sprites[1].animation == StringName("idle_" + direction), "stop retains facing")
		await capture(direction + "-idle")
		# Resume then turn while walking on the next iteration.
		for sprite in sprites:
			Direction.play_direction(sprite, direction, true)
		await process_frame
	catalog.release(restored.key)
	catalog.release(alternate.key)
	print("Canonical motion: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func verify(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path("res://../build/verification/canonical-motion")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))
