extends Node3D
## One street companion; the player's existing body remains the movement authority.

const DirectionalAnimation = preload("res://player/directional_animation.gd")
const REACH := 2.2
const SPEED_MULTIPLIER := 1.8
const RIDER_LIFT := 0.85
const SHEET = preload("res://assets/art/characters/chicken.png")
const ROWS := {"down": 0, "left": 1, "up": 2, "down_left": 3}

var session: Node3D
var mounted := false
var recruited := false
var place_id: StringName = &"street"
var indoors := false
var home_position := Vector3(-6.8, 0.30, 29.0) * 1.45
var facing: StringName = &"down_left"
var sprite: AnimatedSprite3D
var prompt: Label3D
var rider_position := Vector3.ZERO
var last_safe_position := Vector3.ZERO

@onready var player: CharacterBody3D = session.player
@onready var rider: AnimatedSprite3D = player.get_node("PixelCharacter")
@onready var touch: Control = session.touch_controls


func _ready() -> void:
	process_physics_priority = 2
	position = home_position
	last_safe_position = home_position
	rider_position = rider.position
	sprite = AnimatedSprite3D.new()
	sprite.name = "Chicken"
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.pixel_size = 0.04
	sprite.position.y = 1.12
	sprite.sprite_frames = make_frames()
	add_child(sprite)
	sprite.play(&"idle_down_left")
	prompt = Label3D.new()
	prompt.position.y = 3.0
	prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	prompt.font_size = 32
	prompt.outline_size = 8
	add_child(prompt)
	touch.mount_requested.connect(toggle_mount)
	player.respawned.connect(reset_home)
	call_deferred("ground_home")


func make_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for direction in ROWS:
		for walking in [false, true]:
			var animation := StringName(("walk_" if walking else "idle_") + direction)
			frames.add_animation(animation)
			frames.set_animation_speed(animation, 8)
			for column in [1, 0, 2, 0] if walking else [0]:
				var texture := AtlasTexture.new()
				texture.atlas = SHEET
				texture.region = Rect2(column * 64, ROWS[direction] * 64, 64, 64)
				frames.add_frame(animation, texture)
	return frames


func ground_home() -> void:
	await get_tree().physics_frame
	# At startup the street may already be hidden; its authored route gives the fallback.
	var ground := grounded_point(home_position)
	if ground != Vector3.INF:
		home_position = ground
		position = ground
	last_safe_position = home_position


func can_interact() -> bool:
	return (
		session.current_id == place_id
		and session.inside_salon == indoors
		and not session.busy
		and not session.map_ui.is_open
		and not session.dialogue.is_open
		and not session.bag_ui.is_open
		and not session.item_loop.placement_active
		and not player.input_locked
		and not touch.portrait
		and player.is_on_floor()
		and (mounted or player.global_position.distance_to(global_position) <= REACH)
	)


func toggle_mount() -> void:
	if not can_interact():
		return
	if mounted:
		dismount()
	else:
		mounted = true
		recruited = true
		facing = rider.facing
		player.movement_speed_multiplier = SPEED_MULTIPLIER
		rider.riding = true
		rider.position = rider_position + Vector3.UP * RIDER_LIFT
		global_position = player.global_position
		last_safe_position = global_position
	touch.mounted = mounted
	touch.queue_redraw()


func dismount() -> void:
	if not mounted:
		return
	mounted = false
	player.movement_speed_multiplier = 1.0
	rider.riding = false
	rider.position = rider_position
	# Never teleport the player into a wall. Park beside their grounded footprint.
	global_position = last_safe_position
	if player.is_on_floor():
		global_position = player.global_position
		park_beside_player()
	touch.mounted = false
	touch.queue_redraw()


func reset_home() -> void:
	dismount()
	arrive_with_player()


func arrive_with_player() -> void:
	if not recruited:
		return
	place_id = session.current_id
	indoors = session.inside_salon
	global_position = player.global_position
	last_safe_position = global_position
	if not mounted:
		park_beside_player()


func park_beside_player() -> void:
	var camera: Camera3D = session.camera_rig.get_node("Camera")
	var side := camera.global_basis.x
	side.y = 0
	for offset in [side.normalized(), -side.normalized()]:
		var point := grounded_point(player.global_position + offset * 1.25)
		if point == Vector3.INF or absf(point.y - player.global_position.y) > 0.4:
			continue
		var query := PhysicsRayQueryParameters3D.create(
			player.global_position + Vector3.UP * 0.7, point + Vector3.UP * 0.7, 1
		)
		if get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			global_position = point
			break


func grounded_point(at: Vector3) -> Vector3:
	var ray := PhysicsRayQueryParameters3D.create(at + Vector3.UP, at - Vector3.UP * 1.5, 1)
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	if hit.is_empty() or hit.normal.y < 0.7:
		return Vector3.INF
	return hit.position


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F and can_interact():
			toggle_mount()
			get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	visible = (
		session.current_id == place_id and session.inside_salon == indoors and not session.busy
	)
	var walking := false
	if mounted:
		global_position = player.global_position
		if player.is_on_floor():
			last_safe_position = global_position
		var motion := player.get_real_velocity()
		motion.y = 0
		walking = motion.length() > 0.12
		if walking:
			facing = DirectionalAnimation.resolve_facing(
				motion, session.camera_rig.get_node("Camera"), facing, true
			)
	var direction := String(facing)
	# Front-facing neck covers the rider's lower body; rear views show the saddle.
	# Move along the view axis to change depth without moving its on-screen feet.
	sprite.position = Vector3.UP * 1.12
	if mounted and direction == "down":
		sprite.position += session.camera_rig.get_node("Camera").global_basis.z * 1.1
	if mounted:
		var lift := RIDER_LIFT + (0.45 if direction == "down" else 0.0)
		rider.position = rider_position + Vector3.UP * lift
	sprite.flip_h = direction.contains("right")
	direction = direction.replace("right", "left")
	if direction == "up_left":
		direction = "up"
	DirectionalAnimation.play_direction(sprite, StringName(direction), walking)
	touch.mount_available = can_interact()
	touch.mounted = mounted
	prompt.visible = touch.mount_available and not touch.enabled
	prompt.text = "F · Bajar" if mounted else "F · Montar gallina"
