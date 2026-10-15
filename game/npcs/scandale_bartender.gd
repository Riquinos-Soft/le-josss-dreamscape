extends "res://npcs/lourizan_guide.gd"
## Fictional bartender inspired only by the supplied visual reference.

const Catalog = preload("res://v2/characters/appearance_catalog.gd")
const Jokes = preload("res://dialogue/scandale_jokes.gd")
var catalog := Catalog.new()
var composition_key := ""
var previous_joke := -1
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	var config := Catalog.preset()
	config.hair_palette = "blond"
	config.upper_palette = "navy"
	var result := catalog.acquire(config)
	assert(result.ok)
	composition_key = result.key
	sprite.sprite_frames = result.frames
	super()


func _exit_tree() -> void:
	catalog.release(composition_key)


func next_dialogue_pages() -> Array[String]:
	previous_joke = Jokes.choose(previous_joke, rng)
	return [Jokes.JOKES[previous_joke]]


func can_talk(player: Node3D) -> bool:
	if player.global_position.distance_to(global_position) > 2.4:
		return false
	# Eye-level conversation can cross the solid 1.1 m countertop, not walls.
	var query := PhysicsRayQueryParameters3D.create(
		player.global_position + Vector3.UP * 1.5, head.global_position, 1
	)
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()
