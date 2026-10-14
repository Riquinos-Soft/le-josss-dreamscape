extends Control
## A small laboratory input adapter; keyboard and one touch stick share intent.

const Direction = preload("res://player/movement_direction.gd")
const RADIUS := 65.0
var actor: CharacterBody3D
var camera: Camera3D
var finger := -1
var touch_value := Vector2.ZERO
var center := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_physics_priority = -1
	get_viewport().size_changed.connect(clear_input)
	actor.respawned.connect(clear_input)


func _physics_process(_delta: float) -> void:
	var value := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if value.is_zero_approx():
		value = touch_value
	actor.set_movement_intent(Direction.from_view(value, camera.global_basis))


func _input(event: InputEvent) -> void:
	handle_touch(event)


func handle_touch(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.index == finger and (not event.pressed or event.canceled):
			clear_touch()
		elif event.pressed and finger == -1 and event.position.x < size.x * 0.5:
			finger = event.index
			center = event.position
	elif event is InputEventScreenDrag and event.index == finger:
		touch_value = ((event.position - center) / RADIUS).limit_length(1.0)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		clear_input()


func clear_touch() -> void:
	finger = -1
	touch_value = Vector2.ZERO
	queue_redraw()


func clear_input() -> void:
	clear_touch()
	actor.set_movement_intent(Vector3.ZERO)
	for action in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(action)
	queue_redraw()


func _draw() -> void:
	if finger >= 0:
		draw_circle(center, RADIUS, Color(0.8, 0.85, 0.7, 0.2))
		draw_circle(center + touch_value * RADIUS, 18, Color(0.9, 0.85, 0.7, 0.7))
