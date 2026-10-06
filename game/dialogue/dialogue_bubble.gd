extends CanvasLayer
## A screen-clamped, speaker-anchored paged balloon for one active conversation.

signal closed

var is_open := false
var page_index := 0
var pages: Array[String] = []
var anchor: Node3D
var panel: PanelContainer
var speaker_label: Label
var body_label: Label
var continue_button: Button
var close_button: Button
var tail: Label


func _ready() -> void:
	layer = 20
	build_ui()
	get_viewport().size_changed.connect(update_layout)


func build_ui() -> void:
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 180)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color("172329")
	style.border_color = Color("d0b66a")
	style.set_border_width_all(4)
	style.set_corner_radius_all(3)
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 8
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	panel.add_child(margin)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	margin.add_child(rows)
	var heading := HBoxContainer.new()
	rows.add_child(heading)
	speaker_label = Label.new()
	speaker_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speaker_label.add_theme_color_override("font_color", Color("f1d786"))
	speaker_label.add_theme_font_size_override("font_size", 20)
	heading.add_child(speaker_label)
	close_button = Button.new()
	close_button.text = "×"
	close_button.custom_minimum_size = Vector2(48, 42)
	close_button.pressed.connect(close)
	heading.add_child(close_button)
	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_label.add_theme_color_override("font_color", Color("f4f0dc"))
	body_label.add_theme_font_size_override("font_size", 18)
	rows.add_child(body_label)
	continue_button = Button.new()
	continue_button.custom_minimum_size = Vector2(150, 48)
	continue_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	continue_button.pressed.connect(advance)
	rows.add_child(continue_button)
	tail = Label.new()
	tail.text = "▼"
	tail.add_theme_color_override("font_color", Color("d0b66a"))
	tail.add_theme_font_size_override("font_size", 22)
	tail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tail)
	panel.hide()
	tail.hide()


func open(speaker: String, speaker_anchor: Node3D, paragraphs: Array[String]) -> void:
	if paragraphs.is_empty() or not is_instance_valid(speaker_anchor):
		return
	is_open = true
	page_index = 0
	pages = paragraphs.duplicate()
	anchor = speaker_anchor
	speaker_label.text = speaker
	panel.show()
	tail.show()
	show_page()
	continue_button.grab_focus()
	call_deferred("update_layout")


func advance() -> void:
	if not is_open:
		return
	if page_index >= pages.size() - 1:
		close()
		return
	page_index += 1
	show_page()


func close() -> void:
	if not is_open:
		return
	is_open = false
	pages.clear()
	anchor = null
	panel.hide()
	tail.hide()
	get_viewport().gui_release_focus()
	closed.emit()


func show_page() -> void:
	body_label.text = pages[page_index]
	continue_button.text = "Terminar" if page_index == pages.size() - 1 else "Continuar"


func _process(_delta: float) -> void:
	if is_open:
		if not is_instance_valid(anchor):
			close()
		else:
			update_layout()


func update_layout() -> void:
	if not is_open or not is_instance_valid(anchor):
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var compact := get_window().size.x < 900
	var width := minf(520.0, viewport_size.x - 32.0)
	var height := maxf(210.0 if compact else 190.0, panel.get_combined_minimum_size().y)
	panel.size = Vector2(width, height)
	body_label.add_theme_font_size_override("font_size", 16 if compact else 18)
	var projected := camera.unproject_position(anchor.global_position)
	var desired := projected + Vector2(-width / 2.0, -height - 34.0)
	panel.position = Vector2(
		clampf(desired.x, 16.0, viewport_size.x - width - 16.0),
		clampf(desired.y, 16.0, viewport_size.y - height - 16.0)
	)
	tail.position = Vector2(
		clampf(projected.x - 10.0, 18.0, viewport_size.x - 38.0),
		panel.position.y + panel.size.y - 1.0
	)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE:
			close()
		else:
			match event.physical_keycode:
				KEY_E, KEY_ENTER, KEY_SPACE:
					advance()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		close()
