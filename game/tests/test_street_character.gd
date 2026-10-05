extends SceneTree
## Exercise actual controller displacement, collisions and animated presentation together.

const DIRECTIONS := [
	"down", "up", "left", "right", "down_left", "down_right", "up_left", "up_right"
]
const INPUTS := [
	Vector2(0, 1),
	Vector2(0, -1),
	Vector2(-1, 0),
	Vector2(1, 0),
	Vector2(-1, 1),
	Vector2(1, 1),
	Vector2(-1, -1),
	Vector2(1, -1)
]
var checks := 0
var failures := 0
var actor: CharacterBody3D
var character: AnimatedSprite3D
var camera: Camera3D


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var world := Node3D.new()
	root.add_child(world)
	current_scene = world
	add_box(world, Vector3(0, -0.5, 0), Vector3(100, 1, 100))
	camera = Camera3D.new()
	world.add_child(camera)
	camera.position = Vector3(9, 12, 12)
	camera.look_at(Vector3.ZERO)
	actor = load("res://player/player.tscn").instantiate()
	actor.movement_orientation = camera
	world.add_child(actor)
	character = AnimatedSprite3D.new()
	character.set_script(load("res://player/street_character.gd"))
	character.sprite_frames = load("res://assets/art/characters/char_joss_animations_v01.tres")
	character.movement_actor = actor
	character.movement_view = camera
	actor.add_child(character)
	await frames(5)
	for direction in DIRECTIONS:
		var clip := StringName("walk_" + direction)
		check(character.sprite_frames.get_frame_count(clip) == 4, "four walk poses " + direction)
		check(character.sprite_frames.get_animation_speed(clip) == 8, "walk cadence " + direction)
		var previous: PackedByteArray
		for index in 4:
			var texture := character.sprite_frames.get_frame_texture(clip, index) as AtlasTexture
			var image := texture.atlas.get_image().get_region(Rect2i(texture.region))
			var bounds := image.get_used_rect()
			check(bounds.end.y == 60 and bounds.size.y <= 48, "walk feet and height " + direction)
			check(
				index == 0 or image.get_data() != previous, "distinct successive poses " + direction
			)
			previous = image.get_data()
	for yaw in [0.0, PI / 2.0]:
		camera.rotation.y += yaw
		for index in 8:
			actor.position = Vector3.ZERO
			actor.velocity = Vector3.ZERO
			steer(INPUTS[index])
			await frames(12)
			check(
				character.animation == "walk_" + DIRECTIONS[index],
				"walk facing " + DIRECTIONS[index]
			)
			var visited: Array[int] = []
			for tick in 35:
				await frames(1)
				if character.frame not in visited:
					visited.append(character.frame)
			check(visited.size() == 4, "cycle advances without restart " + DIRECTIONS[index])
			steer(Vector2.ZERO)
			await frames(3)
			check(
				character.animation == "idle_" + DIRECTIONS[index],
				"idle keeps facing " + DIRECTIONS[index]
			)
	# Check both sides of sector boundaries through analog input and the real controller.
	for entry in [[22.4, "right"], [22.6, "down_right"], [-22.4, "right"], [-22.6, "up_right"]]:
		actor.position = Vector3.ZERO
		steer(Vector2.from_angle(deg_to_rad(entry[0])))
		await frames(5)
		check(character.animation == "walk_" + entry[1], "sector boundary " + str(entry[0]))
	steer(Vector2.ZERO)
	camera.rotation = Vector3.ZERO
	actor.position = Vector3.ZERO
	actor.velocity = Vector3.ZERO
	add_box(world, Vector3(2, 1, 0), Vector3(1, 2, 8))
	steer(Vector2.RIGHT)
	await frames(65)
	var blocked_position := actor.position
	await frames(20)
	check(actor.position.distance_to(blocked_position) < 0.01, "real wall blocks walking")
	check(character.animation == "idle_right", "held input against wall does not animate walking")
	steer(Vector2.ZERO)
	actor.position = Vector3(20, -12, 20)
	await frames(1)
	check(character.animation == "idle_up", "respawn clears stale walk state")
	print("Street character: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func add_box(world: Node3D, position: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = position
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	world.add_child(body)


func steer(input: Vector2) -> void:
	for action in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(action)
	if input.x < 0:
		Input.action_press("move_left", -input.x)
	if input.x > 0:
		Input.action_press("move_right", input.x)
	if input.y < 0:
		Input.action_press("move_forward", -input.y)
	if input.y > 0:
		Input.action_press("move_back", input.y)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)
