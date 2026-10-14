extends SceneTree
## Identity, rejection, cache ownership and phase continuity across real compositions.

const Catalog = preload("res://v2/characters/appearance_catalog.gd")
const DirectionalAnimation = preload("res://player/directional_animation.gd")
var checks := 0
var failures := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var started := Time.get_ticks_msec()
	var catalog := Catalog.new()
	var primary := Catalog.preset()
	var alternative := Catalog.preset(true)
	var first: Dictionary = catalog.acquire(primary)
	var second: Dictionary = catalog.acquire(alternative)
	var npc: Dictionary = catalog.acquire(alternative)
	check(first.ok and second.ok, "both appearance configurations compose")
	check(second.frames == npc.frames, "matching NPC configuration reuses composition")
	check(catalog.cache.size() == 2, "only two distinct compositions are retained")
	var changed := primary.duplicate()
	changed.hair = "res://arbitrary.gd"
	check(not catalog.acquire(changed).ok, "resource path cannot be an appearance ID")
	changed = primary.duplicate()
	changed.version = 2
	check(Catalog.validate(changed) == "unsupported_version", "version requires explicit migration")
	changed = primary.duplicate()
	changed.extra = true
	check(Catalog.validate(changed) == "invalid_fields", "extra fields are rejected")
	changed = primary.duplicate()
	changed.upper_palette = "warm"
	check(Catalog.validate(changed) == "unknown_upper_palette", "palette is restricted to its part")
	for result in [first, second]:
		var frames: SpriteFrames = result.frames
		check(frames.get_animation_names().size() == 16, "eight idle and walk directions")
		for direction in Catalog.DIRECTIONS:
			var idle := StringName("idle_" + direction)
			var walk := StringName("walk_" + direction)
			check(frames.get_frame_count(idle) == 1, "one straight-leg idle: " + direction)
			check(frames.get_frame_count(walk) == 4, "four walking phases: " + direction)
			var idle_image := frames.get_frame_texture(idle, 0).get_image()
			check(
				idle_image.get_used_rect().end.y == 60, "idle feet use fixed baseline: " + direction
			)
			var head := idle_image.get_region(Rect2i(19, 13, 28, 20)).get_data()
			for phase in 4:
				var image := frames.get_frame_texture(walk, phase).get_image()
				var bob := -1 if phase in [1, 3] else 0
				check(image.get_used_rect().end.y == 60, "walk foot baseline: " + direction)
				check(
					image.get_region(Rect2i(19, 13 + bob, 28, 20)).get_data() == head,
					"exact head identity after anchor translation: " + direction
				)
	for direction in ["up", "up_left", "up_right"]:
		var row := Catalog.DIRECTIONS.find(direction)
		for face in ["face_plain", "face_freckles"]:
			check(
				(
					catalog
					. textures[face]
					. get_image()
					. get_region(Rect2i(0, row * 64, 320, 64))
					. is_invisible()
				),
				"back-facing facial detail is absent: " + direction
			)
	var sprite := AnimatedSprite3D.new()
	sprite.sprite_frames = first.frames
	sprite.play(&"walk_down")
	sprite.set_frame_and_progress(2, 0.4)
	DirectionalAnimation.play_direction(sprite, &"left", true)
	check(
		sprite.frame == 2 and is_equal_approx(sprite.frame_progress, 0.4),
		"turn preserves walking phase"
	)
	sprite.free()
	catalog.release(second.key)
	check(catalog.cache.has(npc.key), "NPC retains shared composition after player release")
	catalog.release(npc.key)
	check(not catalog.cache.has(npc.key), "last user releases composition")
	catalog.release(first.key)
	check(catalog.cache.is_empty(), "unused cache is released")
	var unavailable := Catalog.new()
	unavailable.textures.erase("hair_tied_front")
	var stored := alternative.duplicate(true)
	var fallback := unavailable.acquire(stored)
	check(
		fallback.ok and fallback.warnings == ["unavailable_hair:tied"],
		"known missing optional hair uses explicit fallback"
	)
	check(stored == alternative, "fallback does not overwrite stored IDs")
	unavailable.release(fallback.key)
	unavailable.textures.erase("body")
	check(not unavailable.acquire(primary).ok, "missing mandatory part is an explicit failure")
	var scene = load("res://v2/validation/laboratory.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await physics_frame
	scene.input_adapter.set_physics_process(false)
	var actor = scene.actor
	var collider = actor.get_child(0)
	var original_pose: Transform3D = actor.transform
	var original_shape = collider.shape
	scene.presenter.play(&"walk_down")
	scene.presenter.set_frame_and_progress(3, 0.25)
	scene.toggle_appearance()
	check(
		actor.transform == original_pose and collider.shape == original_shape,
		"configuration change preserves actor pose and collision"
	)
	check(
		scene.presenter.frame == 3 and is_equal_approx(scene.presenter.frame_progress, 0.25),
		"appearance change preserves animation phase"
	)
	check(
		scene.presenter.sprite_frames == scene.npc_presenter.sprite_frames,
		"player and NPC share presenter frames"
	)
	var previous = scene.presenter.sprite_frames
	check(
		scene.presenter.apply_appearance(changed) != "", "presenter reports invalid configuration"
	)
	check(scene.presenter.sprite_frames == previous, "invalid change preserves visible appearance")
	scene.free()
	print(
		(
			"V2 appearance: %d checks, %d failures; %d ms"
			% [checks, failures, Time.get_ticks_msec() - started]
		)
	)
	quit(1 if failures else 0)


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)
