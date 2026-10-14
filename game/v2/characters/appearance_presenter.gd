extends "res://player/street_character.gd"
## Appearance changes replace frames only; the movement actor keeps its identity.

var catalog: RefCounted
var configuration := {}
var appearance_warnings: Array = []
var composition_key := ""


func apply_appearance(config: Dictionary) -> String:
	var result: Dictionary = catalog.acquire(config)
	if not result.ok:
		return result.error
	var previous_animation := animation
	var previous_frame := frame
	var previous_progress := frame_progress
	var old_key := composition_key
	composition_key = result.key
	configuration = config.duplicate(true)
	appearance_warnings = result.warnings
	sprite_frames = result.frames
	if sprite_frames.has_animation(previous_animation):
		play(previous_animation)
		set_frame_and_progress(previous_frame, previous_progress)
	if old_key != "":
		catalog.release(old_key)
	return ""


func _exit_tree() -> void:
	if catalog != null and composition_key != "":
		catalog.release(composition_key)
		composition_key = ""
