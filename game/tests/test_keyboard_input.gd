extends SceneTree
## Check actual keyboard-event mapping; action_press bypasses this path.

var failures: int = 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var bindings := {
		KEY_W: "move_forward", KEY_UP: "move_forward",
		KEY_S: "move_back", KEY_DOWN: "move_back",
		KEY_A: "move_left", KEY_LEFT: "move_left",
		KEY_D: "move_right", KEY_RIGHT: "move_right",
	}
	for device in [0, 1]:
		for key in bindings:
			var event := InputEventKey.new()
			event.device = device
			event.physical_keycode = key
			event.keycode = key
			event.pressed = true
			Input.parse_input_event(event)
			Input.flush_buffered_events()
			if not Input.is_action_pressed(bindings[key]):
				failures += 1
				push_error("Key %s on device %d did not activate %s" % [key, device, bindings[key]])
			var release := event.duplicate() as InputEventKey
			release.pressed = false
			Input.parse_input_event(release)
			Input.flush_buffered_events()
			if Input.is_action_pressed(bindings[key]):
				failures += 1
				push_error("Key release left %s active" % bindings[key])
	print("Keyboard mapping: 32 checks, %d failures" % failures)
	quit(0 if failures == 0 else 1)
