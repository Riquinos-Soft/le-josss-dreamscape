extends Node3D
## One small zone. Only this process submits durable positions to the service.

const Actor = preload("res://v2/characters/actor.gd")
const Destinations = preload("res://v2/locations/destinations.gd")
const History = preload("res://dialogue/lourizan_history.gd")
const MAX_PEERS := 8
var listener := TCPServer.new()
var peers: Array[Dictionary] = []
var epoch := ""
var api := "http://127.0.0.1:8008/internal/"
var secret := ""
var heartbeat_pending := false
var next_heartbeat := 0
var lease_until := 0
var snapshot_elapsed := 0.0
var zones := {}


func _ready() -> void:
	Engine.max_fps = 60
	for place in Destinations.PATHS:
		var zone := Node3D.new()
		zone.position.x = zones.size() * 1000.0
		add_child(zone)
		var location := Destinations.create(place, null, false)
		location.name = "Place"
		zone.add_child(location)
		zones[place] = zone
	secret = OS.get_environment("AUTHORITY_SECRET")
	if OS.has_environment("ACCOUNT_INTERNAL_URL"):
		api = OS.get_environment("ACCOUNT_INTERNAL_URL")
	if secret.length() < 32:
		push_error("Authority secret is missing")
		get_tree().quit(1)
		return
	var result := await call_api("start", {})
	if not result.has("epoch"):
		push_error("Account service unavailable at authority startup")
		get_tree().quit(1)
		return
	epoch = result.epoch
	lease_until = Time.get_ticks_msec() + 18000
	var bind := OS.get_environment("GAME_BIND")
	if bind == "":
		bind = "127.0.0.1"
	var port := int(OS.get_environment("GAME_PORT")) if OS.has_environment("GAME_PORT") else 9080
	var error := listener.listen(port, bind)
	if error != OK:
		push_error("Could not listen on game port")
		get_tree().quit(1)
	print("Account zone ready")


func call_api(endpoint: String, body: Dictionary) -> Dictionary:
	var request := HTTPRequest.new()
	request.timeout = 5
	add_child(request)
	body["epoch"] = epoch
	var error := request.request(
		api + endpoint + "/",
		["Content-Type: application/json", "Authorization: Bearer " + secret],
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	if error != OK:
		request.queue_free()
		return {"error": "service_unavailable"}
	var response: Array = await request.request_completed
	request.queue_free()
	if response[0] != HTTPRequest.RESULT_SUCCESS:
		return {"error": "service_unavailable"}
	var parsed: Variant = JSON.parse_string(response[3].get_string_from_utf8())
	if not parsed is Dictionary:
		return {"error": "service_unavailable"}
	return parsed


func _process(delta: float) -> void:
	if epoch == "":
		return
	var now := Time.get_ticks_msec()
	if now > lease_until:
		for peer in peers:
			fail_peer(peer, "authority_lost")
		listener.stop()
		get_tree().quit(1)
		return
	if now >= next_heartbeat and not heartbeat_pending:
		heartbeat()
	if listener.is_connection_available():
		var stream := listener.take_connection()
		if peers.size() >= MAX_PEERS:
			stream.disconnect_from_host()
		else:
			var socket := WebSocketPeer.new()
			socket.inbound_buffer_size = 8192
			socket.outbound_buffer_size = 8192
			socket.max_queued_packets = 32
			if socket.accept_stream(stream) == OK:
				peers.append(
					{
						"socket": socket,
						"born": now,
						"actor": null,
						"busy": false,
						"character": {},
						"last_input": now,
						"last_sequence": -1,
						"save_sequence": 0,
						"next_save": now + 5000,
						"safe": Vector3(-2, 0.05, 1),
						"failed": false,
						"leaving": false,
						"packets": 0,
						"window": now,
						"close_after": 0
					}
				)
	for peer in peers.duplicate():
		poll_peer(peer, now)
	snapshot_elapsed += delta
	if snapshot_elapsed >= 0.1:
		snapshot_elapsed = 0.0
		for peer in peers:
			if peer.actor != null and not peer.failed and not peer.get("travelling", false):
				send(
					peer,
					{
						"type": "snapshot",
						"place": peer.character.place,
						"position": vector_array(peer.actor.position),
						"npcs": npc_states(peer)
					}
				)


func poll_peer(peer: Dictionary, now: int) -> void:
	var socket: WebSocketPeer = peer.socket
	socket.poll()
	if peer.close_after > 0 and now >= peer.close_after:
		socket.close(1000, "finished")
	if socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		if peer.busy:
			return
		if peer.actor != null and not peer.failed:
			peer.leaving = true
			save_peer(peer)
			return
		remove_peer(peer)
		return
	if peer.actor == null and now - peer.born > 7000:
		fail_peer(peer, "handshake_timeout")
	while socket.get_available_packet_count() > 0:
		var packet := socket.get_packet()
		if now - peer.window > 1000:
			peer.window = now
			peer.packets = 0
		peer.packets += 1
		if packet.size() > 1024 or peer.packets > 35:
			fail_peer(peer, "invalid_packet")
			break
		var message: Variant = JSON.parse_string(packet.get_string_from_utf8())
		if not message is Dictionary or message.get("version") != 1:
			fail_peer(peer, "invalid_protocol")
			break
		handle_message(peer, message, now)
	if peer.actor != null and not peer.failed:
		if (
			now - peer.last_input > 400
			or peer.leaving
			or peer.get("travelling", false)
			or peer.has("speaker")
		):
			peer.actor.set_movement_intent(Vector3.ZERO)
		var position: Vector3 = peer.actor.position
		if peer.actor.is_on_floor() and Destinations.valid_position(peer.character.place, position):
			peer.safe = position
		if not peer.busy and not peer.leaving and not peer.get("travelling", false):
			check_passages(peer)
		if (now >= peer.next_save or peer.leaving) and not peer.busy:
			save_peer(peer)


func handle_message(peer: Dictionary, message: Dictionary, now: int) -> void:
	if peer.failed or peer.leaving:
		return
	match message.get("type", ""):
		"hello":
			if peer.actor != null or peer.busy or not message.get("ticket") is String:
				fail_peer(peer, "invalid_handshake")
				return
			admit(peer, message.ticket)
		"move":
			apply_move(peer, message, now)
		"leave":
			release_speaker(peer)
			peer.leaving = true
		"travel":
			request_travel(peer, message.get("destination"))
		"talk":
			request_talk(peer, message.get("speaker"))
		"talk_end":
			release_speaker(peer)
		_:
			fail_peer(peer, "unknown_command")


func admit(peer: Dictionary, ticket: String) -> void:
	peer.busy = true
	var result := await call_api("consume", {"ticket": ticket})
	peer.busy = false
	if result.has("error") or peer.failed:
		fail_peer(peer, result.get("error", "connection_closed"))
		return
	for other in peers:
		if other != peer and other.character.get("id") == result.id:
			fail_peer(other, "session_replaced")
	peer.character = result
	var actor := Actor.new()
	actor.position = Vector3(result.position[0], result.position[1], result.position[2])
	zones[result.place].add_child(actor)
	peer.actor = actor
	peer.safe = actor.position
	actor.spawn_position = actor.position
	send(peer, {"type": "welcome", "character": result})


func save_peer(peer: Dictionary, travelled := false) -> void:
	peer.busy = true
	peer.save_sequence += 1
	var result := await call_api(
		"checkpoint",
		{
			"character_id": peer.character.id,
			"generation": peer.character.generation,
			"sequence": peer.save_sequence,
			"position": vector_array(peer.safe),
			"place": peer.character.place
		}
	)
	peer.busy = false
	peer.next_save = Time.get_ticks_msec() + 5000
	if peer.failed:
		return
	if result.has("error"):
		fail_peer(peer, result.error)
	else:
		send(peer, {"type": "saved", "revision": result.revision, "saved_at": result.saved_at})
		if travelled:
			peer.travelling = false
			send(
				peer,
				{
					"type": "travelled",
					"place": result.place,
					"position": result.position,
					"saved_at": result.saved_at
				}
			)
		if peer.leaving:
			send(peer, {"type": "left"})
			peer.failed = true
			peer.close_after = Time.get_ticks_msec() + 2000


func heartbeat() -> void:
	heartbeat_pending = true
	var result := await call_api("heartbeat", {})
	heartbeat_pending = false
	next_heartbeat = Time.get_ticks_msec() + 5000
	if result.get("ok", false):
		lease_until = Time.get_ticks_msec() + 18000
	else:
		lease_until = 0


func send(peer: Dictionary, data: Dictionary) -> void:
	if peer.socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		data["version"] = 1
		peer.socket.send_text(JSON.stringify(data))


func fail_peer(peer: Dictionary, reason: String) -> void:
	if peer.failed:
		return
	peer.failed = true
	release_speaker(peer)
	if peer.actor != null:
		peer.actor.set_movement_intent(Vector3.ZERO)
	send(peer, {"type": "error", "error": reason})
	peer.close_after = Time.get_ticks_msec() + 2000


func remove_peer(peer: Dictionary) -> void:
	release_speaker(peer)
	if peer.actor != null:
		peer.actor.queue_free()
	peers.erase(peer)


func vector_array(value: Vector3) -> Array:
	return [value.x, value.y, value.z]


func request_travel(peer: Dictionary, destination: Variant) -> void:
	if peer.actor == null:
		fail_peer(peer, "authentication_required")
		return
	if peer.busy or peer.get("travelling", false) or peer.has("speaker"):
		send(peer, {"type": "travel_error", "error": "busy"})
		return
	if not destination is String or not Destinations.PATHS.has(destination):
		send(peer, {"type": "travel_error", "error": "unknown_destination"})
		return
	var location: Node3D = zones[peer.character.place].get_node("Place")
	if (
		destination == peer.character.place
		or not location.get_node("Exit").overlaps_body(peer.actor)
	):
		send(peer, {"type": "travel_error", "error": "exit_required"})
		return
	var marker: Marker3D = zones[destination].get_node("Place/Arrival")
	transfer(peer, destination, marker.global_position)


func transfer(peer: Dictionary, destination: String, point: Vector3) -> void:
	# The client supplies an ID only; arrival/floor come from the authored scene.
	var query := PhysicsRayQueryParameters3D.create(
		point + Vector3.UP * 2, point - Vector3.UP * 3, 1
	)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty() or hit.normal.y < 0.6 or absf(hit.position.y - point.y) > 1.2:
		send(peer, {"type": "travel_error", "error": "unsafe_arrival"})
		return
	var local: Vector3 = zones[destination].to_local(hit.position + Vector3.UP * 0.05)
	if not Destinations.valid_position(destination, local):
		send(peer, {"type": "travel_error", "error": "unsafe_arrival"})
		return
	peer.travelling = true
	peer.actor.set_movement_intent(Vector3.ZERO)
	peer.actor.velocity = Vector3.ZERO
	if peer.actor.get_parent() != zones[destination]:
		peer.actor.reparent(zones[destination], false)
	peer.actor.position = local
	peer.actor.spawn_position = local
	peer.actor.reset_physics_interpolation()
	peer.safe = local
	peer.character.place = destination
	save_peer(peer, true)


func check_passages(peer: Dictionary) -> void:
	if peer.character.place != "lourizan" or peer.has("speaker"):
		return
	var location: Node3D = zones.lourizan.get_node("Place")
	for path in ["TerraceEntrance", "Salon/Exit"]:
		var passage: Area3D = location.get_node(path)
		if passage.overlaps_body(peer.actor):
			var marker: Marker3D = passage.get_node(passage.destination)
			transfer(peer, "lourizan", marker.global_position)
			return


func request_talk(peer: Dictionary, speaker: Variant) -> void:
	if peer.actor == null:
		fail_peer(peer, "authentication_required")
		return
	if peer.get("travelling", false) or peer.leaving or peer.has("speaker"):
		return
	if not speaker is String or speaker not in Destinations.SPEAKERS[peer.character.place]:
		send(peer, {"type": "talk_error", "error": "unknown_speaker"})
		return
	var npc: Node3D = zones[peer.character.place].get_node("Place/" + speaker)
	if npc.conversation_active or not npc.can_talk(peer.actor):
		send(peer, {"type": "talk_error", "error": "out_of_reach"})
		return
	peer.speaker = npc
	npc.set_conversation_active(true)
	peer.actor.set_movement_intent(Vector3.ZERO)
	var pages: Array = []
	if npc.has_method("next_dialogue_pages"):
		pages = npc.next_dialogue_pages()
	elif not npc.dialogue_pages.is_empty():
		pages.assign(npc.dialogue_pages)
	else:
		var previous := int(npc.get_meta("history_index", -1))
		var chosen := History.choose_dialogue(previous)
		npc.set_meta("history_index", chosen)
		pages = History.DIALOGUES[chosen]
	send(peer, {"type": "talked", "speaker": speaker, "pages": pages})


func release_speaker(peer: Dictionary) -> void:
	if peer.has("speaker"):
		if is_instance_valid(peer.speaker):
			peer.speaker.set_conversation_active(false)
		peer.erase("speaker")


func npc_states(peer: Dictionary) -> Dictionary:
	var states := {}
	var location: Node3D = zones[peer.character.place].get_node("Place")
	for path in Destinations.SPEAKERS[peer.character.place]:
		var npc: Node3D = location.get_node(path)
		states[path] = {
			"position": vector_array(location.to_local(npc.global_position)),
			"walking": String(npc.sprite.animation).begins_with("walk_")
		}
	return states


func apply_move(peer: Dictionary, message: Dictionary, now: int) -> void:
	if peer.actor == null:
		fail_peer(peer, "authentication_required")
		return
	if peer.get("travelling", false) or peer.has("speaker"):
		return
	var value: Variant = message.get("intent")
	var sequence: Variant = message.get("sequence")
	if (
		not value is Array
		or value.size() != 2
		or not sequence is float
		or sequence != floor(sequence)
		or sequence <= peer.last_sequence
		or sequence > 9007199254740991.0
	):
		return
	if not value[0] is float or not value[1] is float:
		return
	var intent := Vector3(value[0], 0, value[1])
	if not intent.is_finite() or intent.length() > 1.001:
		return
	peer.last_sequence = sequence
	peer.last_input = now
	peer.actor.set_movement_intent(intent)
