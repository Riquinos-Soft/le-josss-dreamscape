extends AnimatableBody3D
## One fictional guide with a small local patrol. Conversation stays in Dreamscape.

const TALK_RANGE := 2.0
const DirectionalAnimation = preload("res://player/directional_animation.gd")
@export var speaker_name := "Lucas Maconheiro"
@export var dialogue_pages: PackedStringArray = []
@export var patrol_enabled := true
@export var walk_speed := 0.8
@export var waypoint_pause := 1.25
var patrol_offsets := PackedVector3Array(
	[
		Vector3.ZERO,
		Vector3(3.0, 0.0, 1.5),
		Vector3(4.5, 0.0, -1.0),
		Vector3(1.5, 0.0, -2.5),
	]
)

var patrol_origin := Vector3.ZERO
var patrol_point_index := 1
var reached_waypoints := 0
var pause_remaining := 0.6
var conversation_active := false
var movement_view: Camera3D
var facing: StringName = &"down"
@onready var sprite: AnimatedSprite3D = $Sprite
@onready var head: Marker3D = $Head
@onready var talk_marker: Label3D = $TalkMarker


func _ready() -> void:
	add_to_group("lourizan_guide" if patrol_enabled else "lourizan_resident")
	add_to_group("lourizan_speaker")
	talk_marker.hide()
	patrol_origin = position
	_play_animation(false)


func _physics_process(delta: float) -> void:
	if conversation_active or not patrol_enabled:
		_play_animation(false)
		return
	if pause_remaining > 0.0:
		pause_remaining = maxf(0.0, pause_remaining - delta)
		_play_animation(false)
		return
	var target := patrol_origin + patrol_offsets[patrol_point_index]
	var motion := target - position
	motion.y = 0.0
	if motion.length() <= 0.04:
		position.x = target.x
		position.z = target.z
		patrol_point_index = (patrol_point_index + 1) % patrol_offsets.size()
		reached_waypoints += 1
		pause_remaining = waypoint_pause
		_play_animation(false)
		return
	var step := motion.normalized() * minf(walk_speed * delta, motion.length())
	position += step
	_update_facing(step)
	_play_animation(true)


func can_talk(player: Node3D) -> bool:
	if player.global_position.distance_to(global_position) > TALK_RANGE:
		return false
	var query := PhysicsRayQueryParameters3D.create(
		player.global_position + Vector3.UP * 0.9, head.global_position, 1
	)
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func set_prompt_visible(visible: bool) -> void:
	talk_marker.visible = visible


func set_movement_view(view: Camera3D) -> void:
	movement_view = view


func set_conversation_active(active: bool) -> void:
	conversation_active = active
	if not active:
		pause_remaining = 0.6
	_play_animation(false)


func is_inside_patrol_bounds() -> bool:
	var offset := position - patrol_origin
	return offset.x >= -0.05 and offset.x <= 4.55 and offset.z >= -2.55 and offset.z <= 1.55


func _update_facing(motion: Vector3) -> void:
	facing = DirectionalAnimation.resolve_facing(
		motion, movement_view, facing, String(sprite.animation).begins_with("walk_")
	)


func _play_animation(walking: bool) -> void:
	DirectionalAnimation.play_direction(sprite, facing, walking)
