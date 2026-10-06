extends CanvasLayer
## Eight-slot pixel bag. The session owns modal locking and placement transitions.

signal open_requested
signal close_requested
signal slot_selected(index: int)

const Inventory = preload("res://inventory/inventory.gd")
const BAG_ICON: Texture2D = preload("res://assets/art/ui/bag_icon_v01.png")

var inventory: Inventory
var is_open := false
var open_button: Button
var panel: PanelContainer
var occupancy: Label
var feedback: Label
var slot_buttons: Array[Button] = []


func _ready() -> void:
	layer = 15
	build_ui()
	get_viewport().size_changed.connect(update_layout)
	update_layout()


func bind_inventory(value: Inventory) -> void:
	if inventory != null and inventory.changed.is_connected(refresh):
		inventory.changed.disconnect(refresh)
	inventory = value
	if inventory != null:
		inventory.changed.connect(refresh)
	refresh()


func build_ui() -> void:
	open_button = Button.new()
	open_button.name = "BagButton"
	open_button.icon = BAG_ICON
	open_button.expand_icon = true
	open_button.custom_minimum_size = Vector2(68, 68)
	open_button.tooltip_text = "Abrir bolsa (B/P)"
	open_button.mouse_filter = Control.MOUSE_FILTER_STOP
	open_button.pressed.connect(func(): open_requested.emit())
	add_child(open_button)
	panel = PanelContainer.new()
	panel.name = "BagPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("30251f")
	panel_style.border_color = Color("b88a52")
	panel_style.set_border_width_all(5)
	panel_style.set_corner_radius_all(4)
	panel_style.shadow_color = Color(0, 0, 0, 0.65)
	panel_style.shadow_size = 10
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	panel.add_child(margin)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	margin.add_child(rows)
	var heading := HBoxContainer.new()
	rows.add_child(heading)
	var title := Label.new()
	title.text = "BOLSA"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_color_override("font_color", Color("f2d59a"))
	title.add_theme_font_size_override("font_size", 22)
	heading.add_child(title)
	occupancy = Label.new()
	occupancy.add_theme_color_override("font_color", Color("8fd4c7"))
	occupancy.add_theme_font_size_override("font_size", 18)
	heading.add_child(occupancy)
	var close_button := Button.new()
	close_button.name = "CloseButton"
	close_button.text = "×"
	close_button.custom_minimum_size = Vector2(48, 48)
	close_button.pressed.connect(func(): close_requested.emit())
	heading.add_child(close_button)
	var grid := GridContainer.new()
	grid.name = "SlotGrid"
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	rows.add_child(grid)
	for index in Inventory.CAPACITY:
		var button := Button.new()
		button.name = "Slot%d" % index
		button.custom_minimum_size = Vector2(76, 76)
		button.expand_icon = true
		button.focus_neighbor_left = NodePath(
			"../Slot%d" % (index - 1 if index % 4 > 0 else index + 3)
		)
		button.focus_neighbor_right = NodePath(
			"../Slot%d" % (index + 1 if index % 4 < 3 else index - 3)
		)
		button.focus_neighbor_top = NodePath("../Slot%d" % ((index + 4) % 8))
		button.focus_neighbor_bottom = NodePath("../Slot%d" % ((index + 4) % 8))
		button.pressed.connect(func(slot_index: int = index): select_slot(slot_index))
		grid.add_child(button)
		slot_buttons.append(button)
	feedback = Label.new()
	feedback.text = "Selecciona un objeto para colocarlo"
	feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback.add_theme_color_override("font_color", Color("d7c29a"))
	rows.add_child(feedback)
	panel.hide()


func open_bag() -> void:
	if is_open:
		return
	is_open = true
	panel.show()
	open_button.hide()
	refresh()
	for button in slot_buttons:
		if not button.disabled:
			button.grab_focus()
			break
	call_deferred("update_layout")


func close_bag() -> void:
	if not is_open:
		return
	is_open = false
	panel.hide()
	open_button.show()
	get_viewport().gui_release_focus()


func select_slot(index: int) -> void:
	if not is_open or inventory == null or inventory.get_item(index) == null:
		return
	slot_selected.emit(index)


func refresh() -> void:
	if occupancy == null:
		return
	var count := inventory.occupied_count() if inventory != null else 0
	occupancy.text = "%d/%d" % [count, Inventory.CAPACITY]
	for index in slot_buttons.size():
		var item = inventory.get_item(index) if inventory != null else null
		var button := slot_buttons[index]
		button.disabled = item == null
		button.icon = item.definition.icon if item != null else null
		button.text = "" if item != null else str(index + 1)
		button.tooltip_text = item.definition.display_name if item != null else "Slot vacío"


func show_feedback(message: String) -> void:
	feedback.text = message


func update_layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	open_button.position = Vector2(viewport_size.x - 84.0, minf(220.0, viewport_size.y - 84.0))
	var compact := viewport_size.y < 500.0
	var panel_size := Vector2(390, 272 if compact else 292)
	panel.size = panel_size
	panel.position = (viewport_size - panel_size) * 0.5
	for button in slot_buttons:
		button.custom_minimum_size = Vector2(72, 62) if compact else Vector2(76, 76)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode in [KEY_ESCAPE, KEY_B, KEY_P]:
		close_requested.emit()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready() and is_open:
		close_requested.emit()
