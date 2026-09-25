extends SceneTree
## Confirms the imported scan is a walkable, bounded geometry trial.

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var street := load("res://world/jacobo_risa_street.tscn").instantiate() as Node3D
	root.add_child(street)
	current_scene = street
	var visual: MeshInstance3D = street.first_mesh(street.get_node("StreetVisual"))
	check(visual != null, "scan mesh loaded")
	if visual == null:
		quit(1)
		return
	check(visual.mesh.surface_get_array_index_len(0) / 3 <= 50000, "scan within triangle budget")
	var collision := street.get_node("StreetCollision/Collision") as CollisionShape3D
	check(collision.shape is ConcavePolygonShape3D, "scan collision generated")
	var player := street.get_node("Player") as CharacterBody3D
	await frames(120)
	check(player.is_on_floor(), "player settles on scanned street")
	check(player.global_position.y > 0.2, "player stays on street surface")
	print(
		(
			"Street trial: %d checks, %d failures; player at %s"
			% [checks, failures, player.global_position]
		)
	)
	quit(0 if failures == 0 else 1)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
