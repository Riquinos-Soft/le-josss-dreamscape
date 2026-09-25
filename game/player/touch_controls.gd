extends Control
## One finger owns movement; other fingers can aim and use actions independently.

const RADIUS := 110.0
var enabled: bool = false
var stick_finger: int = -1
var stick_center := Vector2.ZERO
var stick_value := Vector2.ZERO
var action_rects: Dictionary = {}
var drag_finger: int = -1
var portrait: bool = false
var message: Label
var feedback_action := ""
var feedback_time := 0.0
@onready var player = get_parent().get_parent().get_node("Player")
@onready var items = get_parent().get_parent().get_node("ItemLoop")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	enabled = DisplayServer.is_touchscreen_available() or "--touch" in OS.get_cmdline_user_args()
	visible = enabled
	if not enabled:
		return
	enable_touch()


func enable_touch() -> void:
	enabled = true
	visible = true
	items.touch_mode = true
	items.get_node("HUD").hide()
	var scene_hud := get_parent().get_parent().get_node_or_null("HUD") as CanvasLayer
	if scene_hud != null:
		scene_hud.hide()
	message = Label.new()
	message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 28)
	add_child(message)
	get_viewport().size_changed.connect(update_layout)
	update_layout()
	player.respawned.connect(reset_touch)


func update_layout() -> void:
	reset_touch()
	var viewport_size := get_viewport_rect().size
	portrait = viewport_size.y > viewport_size.x
	get_tree().paused = portrait
	stick_center = Vector2(170, viewport_size.y - 165)
	action_rects.clear()
	update_actions()
	message.position = Vector2(20, 20)
	message.size = Vector2(viewport_size.x - 40, viewport_size.y - 40 if portrait else 90)
	var font_size := 28
	if portrait:
		font_size = roundi(24.0 * viewport_size.x / maxi(get_window().size.x, 1))
	message.add_theme_font_size_override("font_size", font_size)
	queue_redraw()


func reset_touch() -> void:
	stick_finger = -1
	drag_finger = -1
	stick_value = Vector2.ZERO
	player.touch_direction = Vector2.ZERO
	player.mouse_steering_active = false
	items.commands.clear()
	items.touch_aim_pending = false
	feedback_time = 0.0
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		reset_touch()


func _input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventMouse or event is InputEventKey:
		if (
			portrait
			or (event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION)
		):
			get_viewport().set_input_as_handled()
		return
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag):
		return
	get_viewport().set_input_as_handled()
	if portrait:
		return
	handle_touch(event)


func handle_touch(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if not event.pressed or event.canceled:
			if event.index == drag_finger:
				drag_finger = -1
			if event.index == stick_finger:
				stick_finger = -1
				set_stick(stick_center)
			return
		if event.position.distance_to(stick_center) <= RADIUS and stick_finger == -1:
			stick_finger = event.index
			set_stick(event.position)
			return
		update_actions()
		for action in action_rects:
			if action_rects[action].has_point(event.position):
				items.commands.append(StringName(action))
				feedback_action = action
				feedback_time = 0.16
				queue_redraw()
				return
		if items.placement_active and drag_finger == -1:
			var point: Vector2 = items.camera.unproject_position(items.preview.global_position)
			if event.position.distance_to(point) <= 70.0:
				drag_finger = event.index
	if event.index == stick_finger:
		set_stick(event.position)
	elif event is InputEventScreenDrag and event.index == drag_finger:
		# Dragging over controls must never retarget the preview.
		for rect in action_rects.values():
			if rect.has_point(event.position):
				return
		if event.position.distance_to(stick_center) > RADIUS:
			items.touch_aim = event.position
			items.touch_aim_set = true
			items.touch_aim_pending = true


func set_stick(point: Vector2) -> void:
	stick_value = ((point - stick_center) / RADIUS).limit_length()
	player.touch_direction = stick_value if stick_value.length() > 0.15 else Vector2.ZERO
	queue_redraw()


func _process(delta: float) -> void:
	if not enabled:
		return
	if feedback_time > 0.0:
		feedback_time = maxf(0.0, feedback_time - delta)
		queue_redraw()
	if portrait:
		message.text = "Gira el móvil\npara jugar en horizontal"
	elif items.placement_active:
		message.text = "Arrastra el objeto para moverlo · Verde: puedes confirmar"
	elif items.inventory.item != null:
		message.text = "Objeto recogido · Pulsa Colocar"
	elif items.can_pickup():
		message.text = "Bloque al alcance · Pulsa Recoger"
	else:
		message.text = ""
	update_actions()


func update_actions() -> void:
	var names: Array[String] = []
	if items.placement_active:
		names.append("right")
		if items.target_valid:
			names.append("confirm")
	elif items.inventory.item != null:
		names = ["begin"]
	elif items.can_pickup():
		names = ["pickup"]
	if action_rects.keys() == names:
		return
	action_rects.clear()
	var viewport_size := get_viewport_rect().size
	for i in names.size():
		action_rects[names[i]] = Rect2(
			Vector2(viewport_size.x - 345 + i * 160, viewport_size.y - 150), Vector2(150, 105)
		)
	queue_redraw()


func _draw() -> void:
	if not enabled:
		return
	if portrait:
		draw_rect(get_viewport_rect(), Color("101020"))
		return
	draw_circle(stick_center, RADIUS, Color(0.08, 0.1, 0.18, 0.8))
	draw_arc(stick_center, RADIUS, 0, TAU, 64, Color("91c8ca"), 3, true)
	draw_circle(stick_center + stick_value * RADIUS * 0.65, 38, Color("91c8ca"))
	var labels := {
		"pickup": "Recoger", "begin": "Colocar", "right": "Girar", "confirm": "Confirmar"
	}
	var font := ThemeDB.fallback_font
	for action in action_rects:
		var rect: Rect2 = action_rects[action]
		var pressed: bool = feedback_time > 0.0 and feedback_action == action
		var accent := Color("9ee6ca") if action == "confirm" else Color("b6b1ef")
		draw_style_box(button_style(action, pressed), rect)
		draw_action_icon(action, rect.get_center() + Vector2(0, -18), accent)
		var label: String = labels[action]
		var width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
		draw_string(
			font,
			rect.get_center() + Vector2(-width / 2, 33),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			24,
			Color.WHITE
		)


func draw_action_icon(action: String, center: Vector2, color: Color) -> void:
	match action:
		"confirm":
			draw_polyline(
				PackedVector2Array(
					[center + Vector2(-16, 0), center + Vector2(-4, 11), center + Vector2(18, -13)]
				),
				color,
				4.0,
				true
			)
		"right":
			draw_arc(center, 17, -PI * 0.8, PI * 0.65, 24, color, 3.0, true)
			draw_polyline(
				PackedVector2Array(
					[center + Vector2(-20, 7), center + Vector2(-8, 16), center + Vector2(-5, 2)]
				),
				color,
				3.0,
				true
			)
		_:
			var direction := -1.0 if action == "pickup" else 1.0
			draw_line(center + Vector2(0, -16), center + Vector2(0, 12), color, 3, true)
			var tip := center + Vector2(0, direction * 12)
			draw_polyline(
				PackedVector2Array(
					[tip + Vector2(-9, -direction * 9), tip, tip + Vector2(9, -direction * 9)]
				),
				color,
				3.0,
				true
			)
			draw_polyline(
				PackedVector2Array(
					[
						center + Vector2(-18, 10),
						center + Vector2(-18, 20),
						center + Vector2(18, 20),
						center + Vector2(18, 10)
					]
				),
				color,
				3.0,
				true
			)


func button_style(action: String, pressed: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("173e39") if action == "confirm" else Color("242139")
	if pressed:
		style.bg_color = style.bg_color.lightened(0.2)
	style.border_color = Color("73c5a7") if action == "confirm" else Color("8278b6")
	style.set_border_width_all(2)
	style.set_corner_radius_all(20)
	style.shadow_color = Color(0.02, 0.02, 0.06, 0.45)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 5)
	return style
