extends CanvasLayer
## Small map of the captured real-world locations.

signal open_requested
signal cancel_requested
signal destination_confirmed(destination: StringName)
const ScreenUnits = preload("res://ui/screen_units.gd")

const NAMES := {
	&"street": "Calle Jacobo Risa", &"lourizan": "Pazo de Lourizán", &"scandale": "Bar Scandale"
}
var current: StringName = &"street"
var selected: StringName = &""
var is_open := false
var keyboard_hints := true
var prompt: PanelContainer
var guide: PanelContainer
var guide_label: Label
var overlay: ColorRect
var title: Label
var status: Label
var street_button: Button
var lourizan_button: Button
var scandale_button: Button
var scandale_dot: ColorRect
var travel_button: Button
var back_button: Button
var street_dot: ColorRect
var lourizan_dot: ColorRect
var map_center: CenterContainer
var map_panel: PanelContainer
var map_hint: Label
var map_diagram: Control
var map_rows: VBoxContainer
var map_margin: MarginContainer
var ui_theme := Theme.new()
var map_actions: HBoxContainer


func _ready() -> void:
	guide = PanelContainer.new()
	add_child(guide)
	guide.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	guide.offset_left = -345
	guide.offset_top = 16
	guide.offset_right = -16
	guide.offset_bottom = 76
	guide_label = Label.new()
	guide_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide.add_child(guide_label)
	guide_label.text = "Salida al mapa: sigue la indicación"

	prompt = PanelContainer.new()
	add_child(prompt)
	prompt.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	prompt.offset_left = -195
	prompt.offset_top = 16
	prompt.offset_right = -16
	prompt.offset_bottom = 55
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
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	overlay.add_child(scroll)
	var center := CenterContainer.new()
	map_center = center
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.custom_minimum_size.y = get_viewport().get_visible_rect().size.y
	scroll.add_child(center)
	var panel := PanelContainer.new()
	map_panel = panel
	panel.custom_minimum_size.x = minf(440, get_viewport().get_visible_rect().size.x - 24)
	get_viewport().size_changed.connect(_fit_map_card)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.13, 0.16, 1)
	panel_style.border_color = Color(0.14, 0.73, 0.67, 1)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)
	var margin := MarginContainer.new()
	map_margin = margin
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var rows := VBoxContainer.new()
	map_rows = rows
	rows.add_theme_constant_override("separation", 10)
	margin.add_child(rows)
	title = Label.new()
	title.text = "MAPA · LE JOSS'S DREAMSCAPE"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(title)
	var hint := Label.new()
	map_hint = hint
	hint.text = "Elige a dónde viajar desde esta salida"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(hint)
	map_diagram = make_map_diagram()
	rows.add_child(map_diagram)
	street_button = Button.new()
	street_button.pressed.connect(func(): select(&"street"))
	rows.add_child(street_button)
	lourizan_button = Button.new()
	lourizan_button.pressed.connect(func(): select(&"lourizan"))
	rows.add_child(lourizan_button)
	scandale_button = Button.new()
	scandale_button.pressed.connect(func(): select(&"scandale"))
	rows.add_child(scandale_button)
	status = Label.new()
	rows.add_child(status)
	var actions := HBoxContainer.new()
	map_actions = actions
	rows.add_child(actions)
	travel_button = Button.new()
	travel_button.text = "Viajar"
	travel_button.pressed.connect(func(): destination_confirmed.emit(selected))
	actions.add_child(travel_button)
	back_button = Button.new()
	back_button.text = "Volver · Esc"
	back_button.pressed.connect(func(): cancel_requested.emit())
	actions.add_child(back_button)
	for button in [street_button, lourizan_button, scandale_button, travel_button, back_button]:
		button.custom_minimum_size.y = 44
	_fit_map_card()
	overlay.hide()


func show_prompt(available: bool) -> void:
	prompt.visible = keyboard_hints and available and not is_open
	guide.visible = keyboard_hints and not available and not is_open


func set_guide(message: String) -> void:
	guide_label.text = message


func open_map(location: StringName) -> void:
	current = location
	selected = &""
	is_open = true
	overlay.show()
	prompt.hide()
	guide.hide()
	status.text = "Estás aquí: %s" % NAMES[current]
	street_button.disabled = current == &"street"
	lourizan_button.disabled = current == &"lourizan"
	scandale_button.disabled = current == &"scandale"
	travel_button.disabled = true
	back_button.disabled = false
	update_labels()
	(street_button if current != &"street" else lourizan_button).grab_focus()


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
	lourizan_button.disabled = true
	scandale_button.disabled = true
	back_button.disabled = true


func show_error(message: String) -> void:
	status.text = message
	back_button.disabled = false
	street_button.disabled = current == &"street"
	lourizan_button.disabled = current == &"lourizan"
	scandale_button.disabled = current == &"scandale"
	travel_button.disabled = selected == &""
	back_button.grab_focus()


func close_map() -> void:
	is_open = false
	selected = &""
	overlay.hide()
	prompt.hide()
	guide.show()
	get_viewport().gui_release_focus()


func update_labels() -> void:
	scandale_button.text = (
		("> " if selected == &"scandale" else "")
		+ "Bar Scandale"
		+ (" · Estás aquí" if current == &"scandale" else "")
	)
	scandale_dot.color = (
		Color(0.22, 0.96, 0.81)
		if current == &"scandale" or selected == &"scandale"
		else Color(0.52, 0.65, 0.68)
	)
	street_dot.color = (
		Color(0.22, 0.96, 0.81)
		if current == &"street" or selected == &"street"
		else Color(0.52, 0.65, 0.68)
	)
	lourizan_dot.color = (
		Color(0.22, 0.96, 0.81)
		if current == &"lourizan" or selected == &"lourizan"
		else Color(0.52, 0.65, 0.68)
	)
	street_button.text = (
		("> " if selected == &"street" else "")
		+ "Calle Jacobo Risa"
		+ (" · Estás aquí" if current == &"street" else "")
	)
	lourizan_button.text = (
		("> " if selected == &"lourizan" else "")
		+ "Pazo de Lourizán"
		+ (" · Estás aquí" if current == &"lourizan" else "")
	)


func make_map_diagram() -> Control:
	var diagram := HBoxContainer.new()
	diagram.custom_minimum_size.y = 58
	var dots: Array[ColorRect] = []
	var labels := ["Calle", "Lourizán", "Scandale"]
	for i in 3:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		diagram.add_child(column)
		var center := CenterContainer.new()
		column.add_child(center)
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(12, 12)
		center.add_child(dot)
		dots.append(dot)
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = labels[i]
		column.add_child(label)
	street_dot = dots[0]
	lourizan_dot = dots[1]
	scandale_dot = dots[2]
	return diagram


func _fit_map_card() -> void:
	var unit := ScreenUnits.factor(get_viewport())
	var view := get_viewport().get_visible_rect().size
	var compact := view.y / unit < 500
	ui_theme.default_font_size = roundi(16 * unit)
	for control in [map_panel, guide, prompt]:
		control.theme = ui_theme
	map_panel.custom_minimum_size.x = minf(440 * unit, view.x - 24 * unit)
	map_center.custom_minimum_size.y = view.y
	map_hint.visible = not compact
	map_diagram.visible = not compact
	map_actions.add_theme_constant_override("separation", roundi(12 * unit))
	map_rows.add_theme_constant_override("separation", roundi((6 if compact else 10) * unit))
	for side in ["left", "right", "top", "bottom"]:
		map_margin.add_theme_constant_override(
			"margin_" + side, roundi((12 if compact else 18) * unit)
		)
	for button in [street_button, lourizan_button, scandale_button, travel_button, back_button]:
		button.custom_minimum_size.y = 44 * unit
	for dot in [street_dot, lourizan_dot, scandale_dot]:
		dot.custom_minimum_size = Vector2.ONE * 12 * unit
	map_diagram.custom_minimum_size.y = 58 * unit
	guide.offset_left = -345 * unit
	guide.offset_right = -16 * unit
	guide.offset_top = 16 * unit
	guide.offset_bottom = 76 * unit
	prompt.offset_left = -195 * unit
	prompt.offset_right = -16 * unit
	prompt.offset_top = 16 * unit
	prompt.offset_bottom = 60 * unit
