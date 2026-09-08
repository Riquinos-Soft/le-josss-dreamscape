extends SceneTree

const Direction = preload("res://player/movement_direction.gd")
var failures: int = 0


func _initialize() -> void:
	check(Direction.from_view(Vector2.ZERO, Basis.IDENTITY), Vector3.ZERO, "idle")
	check(Direction.from_view(Vector2(0, -1), Basis.IDENTITY), Vector3.FORWARD, "forward")
	check(Direction.from_view(Vector2(1, 0), Basis.IDENTITY), Vector3.RIGHT, "right")
	check(
		Direction.from_view(Vector2(1, -1), Basis.IDENTITY),
		Vector3(1, 0, -1).normalized(),
		"diagonal capped"
	)
	check(
		Direction.from_view(Vector2(0.25, 0), Basis.IDENTITY),
		Vector3(0.25, 0, 0),
		"analog magnitude"
	)
	var turned := Basis(Vector3.UP, PI / 2.0)
	check(Direction.from_view(Vector2(0, -1), turned), Vector3.LEFT, "alternate view heading")
	var pitched := Basis(Vector3.RIGHT, -PI / 4.0)
	check(
		Direction.from_view(Vector2(0, -1), pitched),
		Vector3.FORWARD,
		"pitch does not slow or lift movement"
	)
	check(
		Direction.from_view(Vector2(0, -1), Basis(Vector3.RIGHT, -PI / 2.0)),
		Vector3.FORWARD,
		"overhead view"
	)
	print("Movement direction: 8 checks, %d failures" % failures)
	quit(0 if failures == 0 else 1)


func check(actual: Vector3, expected: Vector3, label: String) -> void:
	if not actual.is_equal_approx(expected):
		push_error("%s: expected %s, got %s" % [label, expected, actual])
		failures += 1
