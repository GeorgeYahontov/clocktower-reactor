extends Node2D

const CylinderProjector = preload("res://scripts/presentation/CylinderProjector.gd")

var state: RefCounted
var projector: CylinderProjector

func bind(game_state: RefCounted) -> void:
	state = game_state
	projector = CylinderProjector.new()

func _draw() -> void:
	if state == null:
		return

	_draw_background()
	_draw_tower_shell()
	_draw_grid_points()
	_draw_enemies()
	_draw_player()

func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#101820"))
	for i in 12:
		var y := 90.0 + float(i) * 92.0
		draw_line(Vector2(0.0, y), Vector2(720.0, y + 32.0), Color(0.12, 0.18, 0.21, 0.28), 2.0)

func _draw_tower_shell() -> void:
	var center: Vector2 = projector.center
	var rect := Rect2(center.x - projector.radius_x, 250.0, projector.radius_x * 2.0, 640.0)
	draw_arc(center, projector.radius_x, PI, TAU, 48, Color(0.24, 0.34, 0.38, 0.7), 6.0)
	draw_line(Vector2(rect.position.x, rect.position.y + 100.0), Vector2(rect.position.x, rect.end.y), Color(0.20, 0.29, 0.32, 0.7), 4.0)
	draw_line(Vector2(rect.end.x, rect.position.y + 100.0), Vector2(rect.end.x, rect.end.y), Color(0.20, 0.29, 0.32, 0.7), 4.0)

func _draw_grid_points() -> void:
	for lane in state.config.lane_count:
		for sector in state.config.sector_count:
			var projected: Dictionary = projector.project(sector, lane, state.tower_rotation, state.config.sector_count)
			if not projected["front"]:
				continue
			var color := Color(0.30, 0.46, 0.48, 0.35 * projected["alpha"])
			draw_circle(projected["position"], 7.0 * projected["scale"], color)

func _draw_enemies() -> void:
	var sorted: Array = state.enemies.duplicate()
	sorted.sort_custom(func(a, b) -> bool:
		var pa: Dictionary = projector.project(a.sector, a.lane, state.tower_rotation, state.config.sector_count)
		var pb: Dictionary = projector.project(b.sector, b.lane, state.tower_rotation, state.config.sector_count)
		return pa["depth"] < pb["depth"]
	)

	for enemy in sorted:
		var projected: Dictionary = projector.project(enemy.sector, enemy.lane, state.tower_rotation, state.config.sector_count)
		if not projected["front"]:
			continue
		var size: Vector2 = Vector2(30.0, 44.0) * projected["scale"]
		var pos: Vector2 = projected["position"] - size * 0.5
		draw_rect(Rect2(pos, size), Color(0.89, 0.34, 0.18, projected["alpha"]), true, 4.0)
		draw_rect(Rect2(pos, size), Color(1.0, 0.84, 0.32, projected["alpha"]), false, 2.0)

func _draw_player() -> void:
	var projected: Dictionary = projector.project(state.player_sector, state.player_lane, state.tower_rotation, state.config.sector_count)
	var position: Vector2 = projected["position"]
	draw_circle(position, 28.0 * projected["scale"], Color("#f2c14e"))
	draw_circle(position + Vector2(0.0, -8.0), 10.0 * projected["scale"], Color("#101820"))
	draw_arc(position, 42.0 * projected["scale"], -0.8, 0.8, 16, Color(0.95, 0.92, 0.62, 0.45), 5.0)
