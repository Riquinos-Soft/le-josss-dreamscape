extends SceneTree
## Remote presence uses the local canonical renderer, without local simulation.

const Catalog = preload("res://v2/characters/appearance_catalog.gd")
const Direction = preload("res://player/directional_animation.gd")
var checks := 0
var failures := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var session: Node3D = load("res://v2/account/session.tscn").instantiate()
	root.add_child(session)
	current_scene = session
	session.get_node("Daylight").preview_hour = 13.0
	session.handle_packet(
		{
			"type": "welcome",
			"character":
			{
				"appearance": Catalog.preset(),
				"position": [9.6, 0.05, 0],
				"saved_at": "2026-10-19T12:00:00Z"
			}
		}
	)
	var remote: Node3D = session.remote_players
	var data := {
		"name": "Segundo",
		"appearance": Catalog.preset(true),
		"position": [8.0, 0.05, -2.0],
		"direction": [1, 0, 0],
		"walking": true
	}
	session.handle_packet(
		{"type": "snapshot", "position": [9.6, 0.05, 0], "players": {"second": data}}
	)
	check(remote.players.size() == 1, "a remote player joins")
	var state: Dictionary = remote.players.second
	check(state.actor.collision_layer == 0, "remote player cannot block local collisions")
	check(not state.actor.is_physics_processing(), "remote player does not simulate movement")
	check(state.presenter.configuration == Catalog.preset(true), "remote appearance is preserved")
	check(state.label.text == "Segundo", "remote name is rendered as plain text")
	check(
		state.presenter.pixel_size == session.presenter.pixel_size, "canonical pixel scale matches"
	)
	check(
		state.presenter.position == session.presenter.position, "canonical sprite placement matches"
	)
	var identity: int = state.actor.get_instance_id()
	data.appearance = Catalog.preset()
	remote.update_players({"second": data})
	check(state.actor.get_instance_id() == identity, "appearance update keeps the remote actor")
	check(
		state.presenter.sprite_frames == session.presenter.sprite_frames,
		"matching appearances reuse the exact canonical pose frames"
	)
	data.appearance = Catalog.preset(true)
	remote.update_players({"second": data})
	for index in range(8):
		var right: Vector3 = session.camera.global_basis.x
		var down: Vector3 = session.camera.global_basis.z
		right.y = 0
		down.y = 0
		var direction := (
			(right.normalized() * cos(index * PI / 4) + down.normalized() * sin(index * PI / 4))
			. normalized()
		)
		data.direction = [direction.x, 0, direction.z]
		remote.update_players({"second": data})
		await process_frame
		await process_frame
		check(
			state.facing == Direction.DIRECTIONS[index],
			"remote direction follows the gameplay camera"
		)
		check(String(state.presenter.animation).begins_with("walk_"), "remote walking animates")
	data.walking = false
	data.position = [8.8, 0.05, -2.0]
	remote.update_players({"second": data})
	for _frame in range(20):
		await process_frame
	check(String(state.presenter.animation).begins_with("idle_"), "stopped remote player idles")
	check(state.actor.position.x > 8.0, "remote position interpolates toward server target")
	if DisplayServer.get_name() != "headless" and "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		var folder := ProjectSettings.globalize_path("res://../build/verification/online")
		DirAccess.make_dir_recursive_absolute(folder)
		root.get_texture().get_image().save_png(folder.path_join("two-characters.png"))
	remote.update_players({})
	check(
		remote.players.is_empty() and remote.get_child_count() == 0, "departure removes the actor"
	)
	remote.update_players({"second": data})
	session.connection_error("connection_lost")
	check(remote.players.is_empty(), "disconnect clears remote ghosts")
	await process_frame
	check(session.catalog.cache.size() == 1, "departed presenters release their cached appearance")
	print("Online players: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
