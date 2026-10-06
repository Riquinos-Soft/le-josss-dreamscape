extends Node3D
## Keep the capture's baked photographic appearance; sunlight lights the player.

@export_range(1.0, 2.0, 0.05) var place_scale := 1.0


func _ready() -> void:
	$CapturedExterior.scale = Vector3.ONE * place_scale
	for name in ["Arrival", "Exit", "PavingSupport", "Player"]:
		if has_node(name):
			get_node(name).position *= place_scale
	if has_node("PavingSupport"):
		$PavingSupport.scale = Vector3.ONE * place_scale
	if has_node("Player"):
		$Player.spawn_transform = $Player.transform
		$Player.reset_physics_interpolation()
		$CameraRig.snap_to_target()
	for visual in $CapturedExterior.find_children("*", "MeshInstance3D", true, false):
		for surface in visual.mesh.get_surface_count():
			var material = visual.get_active_material(surface)
			if material is StandardMaterial3D:
				material = material.duplicate()
				material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				# Blender exports the photographic texture in the emission channel.
				if material.emission_texture != null:
					material.albedo_texture = material.emission_texture
					material.albedo_color = Color.WHITE
					material.emission_enabled = false
				visual.set_surface_override_material(surface, material)
