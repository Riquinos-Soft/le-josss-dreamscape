extends Node3D
## One stationary, fictional guide. Conversation ownership stays in Dreamscape.

const TALK_RANGE := 2.0

@onready var body: StaticBody3D = $Body
@onready var head: Marker3D = $Head
@onready var talk_marker: Label3D = $TalkMarker


func _ready() -> void:
	add_to_group("lourizan_guide")
	talk_marker.hide()


func can_talk(player: Node3D) -> bool:
	if player.global_position.distance_to(global_position) > TALK_RANGE:
		return false
	var query := PhysicsRayQueryParameters3D.create(
		player.global_position + Vector3.UP * 0.9, head.global_position, 1
	)
	query.exclude = [body.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func set_prompt_visible(visible: bool) -> void:
	talk_marker.visible = visible
