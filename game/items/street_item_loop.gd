extends "res://items/item_loop.gd"
## Street presentation uses the shared multi-item/support implementation.


func _ready() -> void:
	super()
	place_button.text = "Bolsa (B/P)"
	call_deferred("settle_initial_item")


func settle_initial_item() -> void:
	await get_tree().physics_frame
	if not is_instance_valid(world_item):
		return
	var supported := supported_pose(world_item.global_position, 0.0)
	if supported != INVALID_TARGET:
		world_item.global_position = supported


func update_hud() -> void:
	place_button.disabled = inventory.occupied_count() == 0 or placement_active
	if placement_active:
		status.text = (
			"Birra Dreamscape · "
			+ ("Puedes colocarla" if target_valid else "Busca suelo libre cercano")
		)
	elif inventory.occupied_count() > 0:
		status.text = (
			"Bolsa %d/%d · B/P para abrir" % [inventory.occupied_count(), Inventory.CAPACITY]
		)
	else:
		status.text = "E · Guardar birra" if can_pickup() else "Acércate a la Birra Dreamscape"
