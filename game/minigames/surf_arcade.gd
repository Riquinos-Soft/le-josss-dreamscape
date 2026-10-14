extends Control
## A self-contained session arcade. Emits one reward only when the result is left.

signal finished(coins: int)

const DESIGN := Vector2(960, 540)
const DURATION := 45.0
const SURFER_Y := 402.0
const JOSS = preload("res://assets/art/characters/joss.tres")

var state := "ready"
var elapsed := 0.0
var scroll := 0.0
var surfer_x := 550.0
var collected := 0
var hearts := 3
var immunity := 0.0
var next_spawn := 0.4
var left_held := false
var right_held := false
var drag_finger := -1
var mouse_drag := false
var drag_target := -1.0
var objects: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var left_button: Button
var right_button: Button
var exit_button: Button
var action_button: Button
var end_reason := ""


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rng.randomize()
	left_button = make_button("◀", func(): pass)
	right_button = make_button("▶", func(): pass)
	left_button.button_down.connect(func(): left_held = true)
	left_button.button_up.connect(func(): left_held = false)
	right_button.button_down.connect(func(): right_held = true)
	right_button.button_up.connect(func(): right_held = false)
	exit_button = make_button("Salir", func(): end_run("Hasta la próxima ola"))
	action_button = make_button("¡Al agua!", main_action)
	resized.connect(layout)
	layout()
	refresh_controls()


func make_button(caption: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.focus_mode = Control.FOCUS_NONE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("153950")
	style.border_color = Color("f6d27a")
	style.set_border_width_all(3)
	button.add_theme_stylebox_override("normal", style)
	var pressed := style.duplicate()
	pressed.bg_color = Color("286c7b")
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover", pressed)
	button.pressed.connect(action)
	add_child(button)
	return button


func layout() -> void:
	var scale_factor := size / DESIGN
	var buttons := [left_button, right_button, exit_button, action_button]
	var positions := [Vector2(24, 430), Vector2(834, 430), Vector2(798, 18), Vector2(355, 356)]
	var sizes := [Vector2(102, 88), Vector2(102, 88), Vector2(138, 52), Vector2(250, 65)]
	for i in buttons.size():
		buttons[i].position = positions[i] * scale_factor
		buttons[i].size = sizes[i] * scale_factor
		buttons[i].add_theme_font_size_override("font_size", roundi(25 * scale_factor.y))
	queue_redraw()


func refresh_controls() -> void:
	left_button.visible = state == "playing"
	right_button.visible = state == "playing"
	exit_button.visible = state != "result" and state != "finished"
	action_button.visible = state in ["ready", "paused", "result"]
	action_button.text = (
		"Volver con Lucas"
		if state == "result"
		else ("Seguir" if state == "paused" else "¡Al agua!")
	)
	queue_redraw()


func main_action() -> void:
	if state == "result":
		state = "finished"
		finished.emit(collected)
	elif state in ["ready", "paused"]:
		state = "playing"
		clear_steering()
		refresh_controls()


func end_run(reason: String) -> void:
	if state in ["result", "finished"]:
		return
	state = "result"
	end_reason = reason
	clear_steering()
	refresh_controls()


func clear_steering() -> void:
	left_held = false
	right_held = false
	drag_finger = -1
	mouse_drag = false
	drag_target = -1


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and state == "playing":
		state = "paused"
		clear_steering()
		refresh_controls()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE:
			end_run("Hasta la próxima ola")
		elif event.physical_keycode in [KEY_ENTER, KEY_SPACE]:
			main_action()
		get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void:
	if state != "playing":
		return
	if event is InputEventScreenTouch:
		if event.pressed and drag_finger == -1:
			drag_finger = event.index
			drag_target = event.position.x / size.x * DESIGN.x
		elif event.index == drag_finger:
			drag_finger = -1
			drag_target = -1
		accept_event()
	elif event is InputEventScreenDrag and event.index == drag_finger:
		drag_target = event.position.x / size.x * DESIGN.x
		accept_event()
	elif event is InputEventMouseButton and event.device != InputEvent.DEVICE_ID_EMULATION:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_drag = event.pressed
			drag_target = event.position.x / size.x * DESIGN.x if mouse_drag else -1.0
	elif event is InputEventMouseMotion and mouse_drag:
		drag_target = event.position.x / size.x * DESIGN.x


func _process(delta: float) -> void:
	if state != "playing":
		return
	var step := minf(delta, 0.05)
	elapsed += step
	var speed := 170.0 + elapsed * 2.3
	scroll += speed * step
	immunity = maxf(0.0, immunity - step)
	var steering := Input.get_axis("move_left", "move_right")
	if is_zero_approx(steering):
		steering = float(right_held) - float(left_held)
	if drag_target >= 0 and is_zero_approx(steering):
		surfer_x = move_toward(surfer_x, drag_target, 360 * step)
	else:
		surfer_x += steering * 360 * step
	surfer_x = clampf(surfer_x, 230, 780)
	next_spawn -= step
	if next_spawn <= 0:
		spawn_line()
		next_spawn = 1.35
	for index in range(objects.size() - 1, -1, -1):
		var object: Dictionary = objects[index]
		object.y += speed * step
		if Vector2(object.x - surfer_x, object.y - SURFER_Y).length() < 29:
			if object.kind == "coin":
				collected += 1
				objects.remove_at(index)
				continue
			if immunity <= 0:
				hearts -= 1
				immunity = 1.5
				if hearts <= 0:
					end_run("¡Menudo chapuzón!")
					break
		if object.y > 580:
			objects.remove_at(index)
	if elapsed >= DURATION and state == "playing":
		end_run("¡Ola completada!")
	queue_redraw()


func spawn_line() -> void:
	var lane := rng.randi_range(0, 4)
	for i in 3:
		objects.append({"kind": "coin", "x": 260.0 + lane * 120, "y": -40.0 - i * 48})
	var rock_lane := posmod(lane + rng.randi_range(1, 4), 5)
	objects.append({"kind": "rock", "x": 260.0 + rock_lane * 120, "y": -90.0})


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, size / DESIGN)
	draw_rect(Rect2(Vector2.ZERO, DESIGN), Color("16788b"))
	# Deliberate blocky shoreline and foam bands, independent from the 3D pixel pass.
	for row in range(-1, 12):
		var y := row * 54.0 + fmod(scroll * 0.4, 54)
		var edge := 145.0 + sin(row * 1.9) * 18
		draw_rect(Rect2(0, y, edge, 56), Color("d2a764"))
		draw_rect(Rect2(0, y, edge - 26, 56), Color("ebce87"))
		draw_rect(Rect2(edge, y, 24, 56), Color("83d6c7"))
		draw_rect(Rect2(edge + 24, y + 8, 8, 34), Color("d8edca"))
		for column in 7:
			var x := 205.0 + column * 115 + sin(row * 2.0 + column) * 25
			draw_rect(Rect2(x, y + 26, 32, 4), Color("3ca6ad"))
			draw_rect(Rect2(x + 10, y + 30, 28, 4), Color("278e9e"))
	for i in 3:
		draw_palm(Vector2(50 + i % 2 * 26, fmod(i * 225 + scroll * 0.25, 700) - 70))
	for object in objects:
		var at := Vector2(roundf(object.x), roundf(object.y))
		if object.kind == "coin":
			draw_coin(at)
		else:
			draw_rock(at)
	draw_surfer()
	draw_rect(Rect2(180, 14, 594, 64), Color("123b50"))
	text_at("SURF", Vector2(200, 54), 26, Color("f7d477"))
	text_at("%02d monedas" % collected, Vector2(302, 54), 24)
	text_at("%02d s" % ceili(maxf(0, DURATION - elapsed)), Vector2(518, 54), 24)
	text_at("♥".repeat(hearts), Vector2(632, 54), 28, Color("f38d7a"))
	if state != "playing":
		draw_overlay()


func draw_surfer() -> void:
	var at := Vector2(roundf(surfer_x), SURFER_Y)
	for i in 4:
		draw_rect(
			Rect2(at + Vector2(-20 + i * 2, 30 + i * 12), Vector2(40 - i * 4, 5)), Color("83d6c7")
		)
	if immunity > 0 and int(immunity * 12) % 2 == 0:
		return
	draw_colored_polygon(
		PackedVector2Array(
			[
				at + Vector2(0, -39),
				at + Vector2(17, -17),
				at + Vector2(15, 29),
				at + Vector2(0, 38),
				at + Vector2(-15, 29),
				at + Vector2(-17, -17)
			]
		),
		Color("f1c469")
	)
	draw_rect(Rect2(at + Vector2(-4, -24), Vector2(8, 49)), Color("d26952"))
	var pose := JOSS.get_frame_texture(&"idle_up", 0)
	draw_texture_rect(pose, Rect2(at + Vector2(-48, -84), Vector2(96, 96)), false)


func draw_coin(at: Vector2) -> void:
	draw_rect(Rect2(at - Vector2(11, 14), Vector2(22, 28)), Color("85512f"))
	draw_rect(Rect2(at - Vector2(14, 10), Vector2(28, 20)), Color("85512f"))
	draw_rect(Rect2(at - Vector2(9, 11), Vector2(18, 22)), Color("edb54b"))
	draw_rect(Rect2(at - Vector2(11, 7), Vector2(22, 14)), Color("edb54b"))
	draw_rect(Rect2(at - Vector2(4, 8), Vector2(5, 16)), Color("fff0a0"))


func draw_rock(at: Vector2) -> void:
	draw_rect(Rect2(at + Vector2(-29, 15), Vector2(58, 5)), Color("a2dbcf"))
	draw_colored_polygon(
		PackedVector2Array(
			[
				at + Vector2(-26, 13),
				at + Vector2(-20, -10),
				at + Vector2(-8, -22),
				at + Vector2(13, -18),
				at + Vector2(25, 11),
				at + Vector2(8, 19)
			]
		),
		Color("364d58")
	)
	draw_rect(Rect2(at + Vector2(-12, -12), Vector2(20, 8)), Color("76918d"))
	draw_rect(Rect2(at + Vector2(0, -4), Vector2(14, 12)), Color("526b70"))


func draw_palm(at: Vector2) -> void:
	draw_rect(Rect2(at, Vector2(10, 52)), Color("89613d"))
	for i in 4:
		draw_rect(
			Rect2(at + Vector2(-26 + i * 8, -14 + i * 5), Vector2(58 - i * 9, 8)), Color("3c7254")
		)
		draw_rect(Rect2(at + Vector2(-10 + i * 6, -28 + i * 5), Vector2(24, 8)), Color("55905c"))


func text_at(value: String, at: Vector2, font_size: int, color := Color("f4ecd3")) -> void:
	draw_string(ThemeDB.fallback_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func draw_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, DESIGN), Color(0.02, 0.08, 0.12, 0.66))
	draw_rect(Rect2(200, 125, 560, 315), Color("153950"))
	draw_rect(Rect2(200, 125, 560, 5), Color("f6d27a"))
	var title := "SURF CON MACONHEIRO"
	var lines := [
		"Recoge monedas y esquiva las rocas.",
		"45 segundos · 3 corazones",
		"A/D o flechas · botones o arrastra en el agua"
	]
	if state == "result":
		title = end_reason
		lines = [
			"Has recogido %d monedas." % collected,
			"Te las llevas al volver con Lucas.",
			"La playa te espera para otra ronda."
		]
	elif state == "paused":
		title = "UN RESPIRO"
		lines = [
			"La ola está en pausa.",
			"Pulsa Seguir cuando estés listo.",
			"Tus monedas siguen contigo."
		]
	text_at(title, Vector2(232, 184), 30, Color("f7d477"))
	for i in lines.size():
		text_at(lines[i], Vector2(232, 236 + i * 36), 21)
