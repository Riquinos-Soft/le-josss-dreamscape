extends Node3D
## Keep the capture's baked photographic appearance; sunlight lights the player.


func _ready() -> void:
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
