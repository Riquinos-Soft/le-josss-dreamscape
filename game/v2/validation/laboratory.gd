extends Node3D
## Isolated P2 collision and appearance route.

const Actor = preload("res://v2/characters/actor.gd")
const LocalInput = preload("res://v2/characters/local_input.gd")
const Presenter = preload("res://v2/characters/appearance_presenter.gd")
const Route = preload("res://v2/validation/collision_route.gd")
const Catalog = preload("res://v2/characters/appearance_catalog.gd")
var actor: CharacterBody3D
var camera: Camera3D
var input_adapter: Control
var presenter: AnimatedSprite3D
var catalog := Catalog.new()
var npc: CharacterBody3D
var npc_presenter: AnimatedSprite3D
var alternate := false
var patrol_direction := 1.0
var verification_running := false
var verification_button: Button
var appearance_button: Button
var verification_status: Label


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
	presenter = make_presenter(actor, false)
	npc = Actor.new()
	npc.name = "SampleNPC"
	npc.position = Vector3(-3, 0.05, 3)
	add_child(npc)
	npc_presenter = make_presenter(npc, true)
	var hud := CanvasLayer.new()
	add_child(hud)
	input_adapter = LocalInput.new()
	input_adapter.actor = actor
	input_adapter.camera = camera
	hud.add_child(input_adapter)
	var label := Label.new()
	label.text = (
		"Laboratorio V2 · personajes por piezas\n"
		+ "WASD / flechas · arrastra a la izquierda para caminar"
	)
	label.position = Vector2(18, 12)
	label.add_theme_font_size_override("font_size", 18)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(label)
	appearance_button = Button.new()
	var button := appearance_button
	button.text = "Cambiar apariencia"
	button.position = Vector2(18, 68)
	button.pressed.connect(toggle_appearance)
	hud.add_child(button)
	verification_button = Button.new()
	verification_button.text = "Verificar recorrido"
	verification_button.position = Vector2(215, 68)
	verification_button.pressed.connect(verify_route)
	hud.add_child(verification_button)
	verification_status = Label.new()
	verification_status.position = Vector2(18, 108)
	verification_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(verification_status)
	if "--verify-route" in OS.get_cmdline_user_args():
		call_deferred("verify_route")


func verify_route() -> void:
	if verification_running:
		return
	verification_running = true
	verification_button.disabled = true
	appearance_button.disabled = true
	verification_status.text = "Verificando paredes, puerta, escalera e input…"
	var result: Dictionary = await Route.new().run(self)
	verification_status.text = (
		"Recorrido: %d/%d correctas" % [result.checks - result.failures, result.checks]
	)
	verification_status.modulate = Color("a8dba0") if result.failures == 0 else Color("e58b7d")
	print("V2 route result: " + JSON.stringify(result))
	verification_running = false
	verification_button.disabled = false
	appearance_button.disabled = false


func make_presenter(body: CharacterBody3D, alternative: bool) -> AnimatedSprite3D:
	var visual := Presenter.new()
	visual.catalog = catalog
	visual.movement_actor = body
	visual.movement_view = camera
	visual.pixel_size = 0.0375
	visual.position.y = 1.05
	visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	visual.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	visual.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	var error := visual.apply_appearance(Catalog.preset(alternative))
	assert(error == "", error)
	body.add_child(visual)
	return visual


func toggle_appearance() -> void:
	alternate = not alternate
	var error: String = presenter.apply_appearance(Catalog.preset(alternate))
	assert(error == "", error)


func _physics_process(_delta: float) -> void:
	if npc.position.x > -2.3:
		patrol_direction = -1.0
	elif npc.position.x < -3.7:
		patrol_direction = 1.0
	npc.set_movement_intent(Vector3(patrol_direction * 0.25, 0, 0))


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
