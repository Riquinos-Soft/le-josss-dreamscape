extends Node3D
## Same-place snapshots reuse canonical sprites without local physics or input.

const Actor = preload("res://v2/characters/actor.gd")
const Presenter = preload("res://v2/characters/appearance_presenter.gd")
const Direction = preload("res://player/directional_animation.gd")
var session: Node3D
var players := {}


func clear() -> void:
	for state in players.values():
		remove_child(state.actor)
		state.actor.queue_free()
	players.clear()


func update_players(snapshot: Dictionary) -> void:
	for id in players.keys():
		if not snapshot.has(id):
			remove_child(players[id].actor)
			players[id].actor.queue_free()
			players.erase(id)
	for id in snapshot:
		var data: Dictionary = snapshot[id]
		var position: Vector3 = session.to_vector(data.position)
		var appearance: Dictionary = data.appearance.duplicate(true)
		appearance.version = int(appearance.version)
		if not players.has(id):
			var actor := Actor.new()
			actor.position = position
			add_child(actor)
			actor.set_physics_process(false)
			actor.collision_layer = 0
			actor.collision_mask = 0
			var presenter := Presenter.new()
			presenter.catalog = session.catalog
			presenter.movement_actor = actor
			presenter.movement_view = session.camera
			presenter.pixel_size = session.presenter.pixel_size
			presenter.position.y = session.presenter.position.y
			presenter.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			presenter.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			presenter.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			if presenter.apply_appearance(appearance) != "":
				remove_child(actor)
				actor.queue_free()
				presenter.free()
				session.connection_error("appearance_unavailable")
				return
			actor.add_child(presenter)
			presenter.set_physics_process(false)
			var label := Label3D.new()
			label.position.y = 2.12
			label.pixel_size = 0.003
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.font_size = 32
			label.outline_size = 8
			label.modulate = Color(1, 0.89, 0.45)
			actor.add_child(label)
			players[id] = {
				"actor": actor,
				"presenter": presenter,
				"label": label,
				"facing": &"down",
				"walking": false
			}
		var state: Dictionary = players[id]
		if state.presenter.configuration != appearance:
			if state.presenter.apply_appearance(appearance) != "":
				session.connection_error("appearance_unavailable")
				return
		state.target = position
		state.label.text = data.name
		state.facing = Direction.resolve_facing(
			session.to_vector(data.direction), session.camera, state.facing, state.walking
		)
		state.walking = data.walking


func _process(delta: float) -> void:
	for state in players.values():
		state.actor.position = state.actor.position.lerp(state.target, minf(15 * delta, 1))
		Direction.play_direction(state.presenter, state.facing, state.walking)
