extends Node3D
## Isolated P2 collision route. Joss is a temporary scale/presentation reference.

const Actor = preload("res://v2/characters/actor.gd")
const LocalInput = preload("res://v2/characters/local_input.gd")
const Presenter = preload("res://player/street_character.gd")
var actor: CharacterBody3D
var camera: Camera3D
var input_adapter: Control
var presenter: AnimatedSprite3D


func _ready() -> void:
	var location := Node3D.new()
	location.name = "Location"
	add_child(location)
	box(location, "Floor", Vector3(0, -0.2, 0), Vector3(14, 0.4, 12), "69745f")
	box(location, "WestWall", Vector3(-6, 1.3, -1), Vector3(0.3, 2.6, 8), "93947e")
	box(location, "DoorLeft", Vector3(-3.4, 1.3, -3), Vector3(5.2, 2.6, 0.3), "a4a08a")
	box(location, "DoorRight", Vector3(3.4, 1.3, -3), Vector3(5.2, 2.6, 0.3), "a4a08a")
	box(location, "Lintel", Vector3(0, 2.4, -3), Vector3(1.6, 0.4, 0.3), "c0b79c")
	for step in 5:
		var height := (step + 1) * 0.2
		box(
			location,
			"Step%d" % step,
			Vector3(1.3 + step * 0.6, height / 2, 0),
			Vector3(0.6, height, 2),
			"b0a78c"
		)
	box(location, "Landing", Vector3(4.8, 0.5, 0), Vector3(1.6, 1, 2), "c0b79c")
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("263c45")
	add_child(environment)
	camera = Camera3D.new()
	add_child(camera)
	camera.position = Vector3(9, 12, 12).normalized() * 60 + Vector3.UP * 0.9
	camera.look_at(Vector3.UP * 0.9)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.5
	camera.far = 200
	camera.current = true
	actor = Actor.new()
	actor.name = "Actor"
	actor.position = Vector3(-2, 0.05, 1)
	add_child(actor)
	presenter = Presenter.new()
	presenter.sprite_frames = preload("res://assets/art/characters/joss.tres")
	presenter.movement_actor = actor
	presenter.movement_view = camera
	presenter.pixel_size = 0.0375
	presenter.position.y = 1.05
	presenter.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	presenter.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	presenter.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	actor.add_child(presenter)
	var hud := CanvasLayer.new()
	add_child(hud)
	input_adapter = LocalInput.new()
	input_adapter.actor = actor
	input_adapter.camera = camera
	hud.add_child(input_adapter)
	var label := Label.new()
	label.text = (
		"Laboratorio V2 · Joss provisional\n"
		+ "WASD / flechas · arrastra a la izquierda para caminar"
	)
	label.position = Vector2(18, 12)
	label.add_theme_font_size_override("font_size", 18)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(label)


func box(parent: Node3D, label: String, at: Vector3, dimensions: Vector3, color: String) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = at
	parent.add_child(body)
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = dimensions
	collider.shape = shape
	body.add_child(collider)
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(color)
	visual.material_override = material
	body.add_child(visual)
