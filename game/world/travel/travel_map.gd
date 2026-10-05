extends CanvasLayer
## Small map of the captured real-world locations.

signal open_requested
signal cancel_requested
signal destination_confirmed(destination: StringName)

const NAMES := {&"street": "Calle Jacobo Risa", &"home": "Casa", &"lourizan": "Pazo de Lourizán"}
var current: StringName = &"street"
var selected: StringName = &""
var is_open := false
var prompt: PanelContainer
var overlay: ColorRect
var title: Label
var status: Label
var street_button: Button
var home_button: Button
var lourizan_button: Button
var travel_button: Button
var back_button: Button
var street_dot: ColorRect
var home_dot: ColorRect
var lourizan_dot: ColorRect


func _ready() -> void:
	prompt = PanelContainer.new()
	prompt.position = Vector2(16, 16)
	add_child(prompt)
	var open_button := Button.new()
	open_button.text = "M · Abrir mapa"
	open_button.focus_mode = Control.FOCUS_NONE
	open_button.pressed.connect(func(): open_requested.emit())
	prompt.add_child(open_button)
	prompt.hide()

	overlay = ColorRect.new()
	overlay.color = Color(0.02, 0.04, 0.06, 0.78)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 360)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.13, 0.16, 1)
	panel_style.border_color = Color(0.14, 0.73, 0.67, 1)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	margin.add_child(rows)
	title = Label.new()
	title.text = "MAPA · LE JOSS'S DREAMSCAPE"
	rows.add_child(title)
	var hint := Label.new()
	hint.text = "Elige a dónde viajar desde esta salida"
	rows.add_child(hint)
	rows.add_child(make_map_diagram())
	street_button = Button.new()
	street_button.pressed.connect(func(): select(&"street"))
	rows.add_child(street_button)
	home_button = Button.new()
	home_button.pressed.connect(func(): select(&"home"))
	rows.add_child(home_button)
	lourizan_button = Button.new()
	lourizan_button.pressed.connect(func(): select(&"lourizan"))
	rows.add_child(lourizan_button)
	status = Label.new()
	rows.add_child(status)
	var actions := HBoxContainer.new()
	rows.add_child(actions)
	travel_button = Button.new()
	travel_button.text = "Viajar"
	travel_button.pressed.connect(func(): destination_confirmed.emit(selected))
	actions.add_child(travel_button)
	back_button = Button.new()
	back_button.text = "Volver · Esc"
	back_button.pressed.connect(func(): cancel_requested.emit())
	actions.add_child(back_button)
	overlay.hide()


func show_prompt(available: bool) -> void:
	prompt.visible = available and not is_open


func open_map(location: StringName) -> void:
	current = location
	selected = &""
	is_open = true
	overlay.show()
	prompt.hide()
	status.text = "Estás aquí: %s" % NAMES[current]
	street_button.disabled = current == &"street"
	home_button.disabled = current == &"home"
	lourizan_button.disabled = current == &"lourizan"
	travel_button.disabled = true
	back_button.disabled = false
	update_labels()
	(street_button if current != &"street" else home_button).grab_focus()


func select(destination: StringName) -> void:
	if not is_open or destination == current or not NAMES.has(destination):
		return
	selected = destination
	travel_button.disabled = false
	status.text = "Destino: %s" % NAMES[destination]
	update_labels()
	travel_button.grab_focus()


func set_loading() -> void:
	status.text = "Cargando destino…"
	travel_button.disabled = true
	street_button.disabled = true
	home_button.disabled = true
	lourizan_button.disabled = true
	back_button.disabled = true


func show_error(message: String) -> void:
	status.text = message
	back_button.disabled = false
	street_button.disabled = current == &"street"
	home_button.disabled = current == &"home"
	lourizan_button.disabled = current == &"lourizan"
	travel_button.disabled = selected == &""
	back_button.grab_focus()


func close_map() -> void:
	is_open = false
	selected = &""
	overlay.hide()
	prompt.hide()
	get_viewport().gui_release_focus()


func update_labels() -> void:
	street_dot.color = (
		Color(0.22, 0.96, 0.81)
		if current == &"street" or selected == &"street"
		else Color(0.52, 0.65, 0.68)
	)
	home_dot.color = (
		Color(0.22, 0.96, 0.81)
		if current == &"home" or selected == &"home"
		else Color(0.52, 0.65, 0.68)
	)
	lourizan_dot.color = (
		Color(0.22, 0.96, 0.81)
		if current == &"lourizan" or selected == &"lourizan"
		else Color(0.52, 0.65, 0.68)
	)
	street_button.text = (
		("✓ " if selected == &"street" else "")
		+ "Calle Jacobo Risa"
		+ (" · Estás aquí" if current == &"street" else "")
	)
	home_button.text = (
		("✓ " if selected == &"home" else "")
		+ "Casa"
		+ (" · Estás aquí" if current == &"home" else "")
	)
	lourizan_button.text = (
		("✓ " if selected == &"lourizan" else "")
		+ "Pazo de Lourizán"
		+ (" · Estás aquí" if current == &"lourizan" else "")
	)


func make_map_diagram() -> Control:
	var diagram := Control.new()
	diagram.custom_minimum_size = Vector2(390, 86)
	var line := Line2D.new()
	line.points = PackedVector2Array([Vector2(68, 29), Vector2(322, 29)])
	line.width = 3.0
	line.default_color = Color(0.31, 0.64, 0.64, 1)
	diagram.add_child(line)
	street_dot = ColorRect.new()
	street_dot.position = Vector2(62, 23)
	street_dot.size = Vector2(12, 12)
	diagram.add_child(street_dot)
	home_dot = ColorRect.new()
	home_dot.position = Vector2(192, 23)
	home_dot.size = Vector2(12, 12)
	diagram.add_child(home_dot)
	lourizan_dot = ColorRect.new()
	lourizan_dot.position = Vector2(316, 23)
	lourizan_dot.size = Vector2(12, 12)
	diagram.add_child(lourizan_dot)
	var street_label := Label.new()
	street_label.position = Vector2(44, 43)
	street_label.text = "Calle"
	diagram.add_child(street_label)
	var home_label := Label.new()
	home_label.position = Vector2(178, 43)
	home_label.text = "Casa"
	diagram.add_child(home_label)
	var lourizan_label := Label.new()
	lourizan_label.position = Vector2(258, 43)
	lourizan_label.text = "Lourizán"
	diagram.add_child(lourizan_label)
	var scale_note := Label.new()
	scale_note.position = Vector2(145, 62)
	scale_note.text = "Esquema · no a escala"
	scale_note.add_theme_color_override("font_color", Color(0.68, 0.76, 0.76, 1))
	diagram.add_child(scale_note)
	return diagram
