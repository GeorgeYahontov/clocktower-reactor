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
	_draw_lane_rings()
	_draw_sector_guides()
	_draw_grid_points()
	_draw_vents()
	_draw_energy_pulses()
	_draw_pulse_effects()
	_draw_shot_traces()
	_draw_enemies()
	_draw_player()
	_draw_result_overlay()

func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#101820"))
	for i in 12:
		var y := 90.0 + float(i) * 92.0
		draw_line(Vector2(0.0, y), Vector2(720.0, y + 32.0), Color(0.12, 0.18, 0.21, 0.28), 2.0)

func _draw_tower_shell() -> void:
	var center: Vector2 = projector.center
	var top_center := Vector2(center.x, 330.0)
	var bottom_center := Vector2(center.x, 885.0)
	_draw_ellipse(top_center, projector.radius_x, 62.0, Color(0.26, 0.42, 0.44, 0.55), 5.0, 0.0, TAU)
	_draw_ellipse(bottom_center, projector.radius_x, 76.0, Color(0.18, 0.30, 0.32, 0.72), 6.0, 0.0, TAU)
	draw_line(Vector2(center.x - projector.radius_x, top_center.y), Vector2(center.x - projector.radius_x, bottom_center.y), Color(0.18, 0.30, 0.32, 0.65), 4.0)
	draw_line(Vector2(center.x + projector.radius_x, top_center.y), Vector2(center.x + projector.radius_x, bottom_center.y), Color(0.18, 0.30, 0.32, 0.65), 4.0)
	_draw_ellipse(Vector2(center.x, 610.0), projector.radius_x + 18.0, 92.0, Color(0.92, 0.82, 0.36, 0.18), 8.0, 0.0, TAU)

func _draw_lane_rings() -> void:
	for lane in state.config.lane_count:
		var lane_y := projector.center.y + projector.base_y - float(lane) * projector.lane_y
		var alpha := 0.45 + float(lane) * 0.08
		_draw_ellipse(Vector2(projector.center.x, lane_y), projector.radius_x, 52.0, Color(0.30, 0.56, 0.58, alpha), 3.0, 0.0, TAU)

func _draw_sector_guides() -> void:
	for sector in state.config.sector_count:
		var bottom: Dictionary = projector.project(sector, 0, state.tower_rotation, state.config.sector_count)
		var top: Dictionary = projector.project(sector, state.config.lane_count - 1, state.tower_rotation, state.config.sector_count)
		if not bottom["front"] and not top["front"]:
			continue
		var alpha: float = 0.18 * maxf(bottom["alpha"], top["alpha"])
		draw_line(bottom["position"], top["position"], Color(0.48, 0.72, 0.72, alpha), 2.0)

func _draw_grid_points() -> void:
	for lane in state.config.lane_count:
		for sector in state.config.sector_count:
			var projected: Dictionary = projector.project(sector, lane, state.tower_rotation, state.config.sector_count)
			if not projected["front"]:
				continue
			var color := Color(0.30, 0.46, 0.48, 0.30 * projected["alpha"])
			draw_circle(projected["position"], 6.0 * projected["scale"], color)

func _draw_vents() -> void:
	for vent in state.vents:
		var projected: Dictionary = projector.project(vent.sector, vent.lane, state.tower_rotation, state.config.sector_count)
		if not projected["front"]:
			continue
		var urgency: float = vent.urgency()
		var radius: float = lerpf(18.0, 34.0, urgency) * projected["scale"]
		var pos: Vector2 = projected["position"]
		var color := Color(0.88, 0.18, 1.0, projected["alpha"])
		var warning := Color(1.0, 0.92, 0.24, projected["alpha"])
		draw_circle(pos, radius, Color(color.r, color.g, color.b, 0.28 * projected["alpha"]))
		draw_arc(pos, radius, -PI * 0.5, -PI * 0.5 + TAU * maxf(0.05, vent.ttl / vent.life), 32, warning, 5.0)
		draw_line(pos + Vector2(0.0, -radius * 0.48), pos + Vector2(0.0, radius * 0.12), color, 5.0)
		draw_circle(pos + Vector2(0.0, radius * 0.48), 3.5 * projected["scale"], color)

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
		if enemy.kind == "bulwark":
			_draw_bulwark(projected)
		else:
			_draw_runner(projected)

func _draw_runner(projected: Dictionary) -> void:
	var size: Vector2 = Vector2(30.0, 44.0) * projected["scale"]
	var pos: Vector2 = projected["position"] - size * 0.5
	draw_rect(Rect2(pos, size), Color(0.89, 0.34, 0.18, projected["alpha"]), true, 4.0)
	draw_rect(Rect2(pos, size), Color(1.0, 0.84, 0.32, projected["alpha"]), false, 2.0)
	draw_line(projected["position"] + Vector2(-8, -4) * projected["scale"], projected["position"] + Vector2(8, -4) * projected["scale"], Color(0.10, 0.06, 0.04, projected["alpha"]), 3.0)

func _draw_bulwark(projected: Dictionary) -> void:
	var center: Vector2 = projected["position"]
	var scale: float = projected["scale"]
	var points := PackedVector2Array([
		center + Vector2(0.0, -34.0) * scale,
		center + Vector2(28.0, -16.0) * scale,
		center + Vector2(22.0, 24.0) * scale,
		center + Vector2(0.0, 36.0) * scale,
		center + Vector2(-22.0, 24.0) * scale,
		center + Vector2(-28.0, -16.0) * scale
	])
	draw_colored_polygon(points, Color(0.35, 0.58, 0.86, projected["alpha"]))
	draw_polyline(points, Color(0.82, 0.96, 1.0, projected["alpha"]), 3.0, true)
	draw_circle(center, 9.0 * scale, Color(0.08, 0.18, 0.28, projected["alpha"]))
	draw_line(center + Vector2(-14.0, -3.0) * scale, center + Vector2(14.0, -3.0) * scale, Color(0.82, 0.96, 1.0, projected["alpha"]), 3.0)

func _draw_shot_traces() -> void:
	for trace in state.shot_traces:
		var start_projected: Dictionary = projector.project(trace["from_sector"], trace["from_lane"], state.tower_rotation, state.config.sector_count)
		var end_projected: Dictionary = projector.project(trace["to_sector"], trace["to_lane"], state.tower_rotation, state.config.sector_count)
		if not start_projected["front"] or not end_projected["front"]:
			continue
		var progress: float = clampf(float(trace["ttl"]) / float(trace["life"]), 0.0, 1.0)
		draw_line(start_projected["position"], end_projected["position"], Color(0.45, 0.95, 1.0, progress), 5.0)
		draw_circle(end_projected["position"], 12.0 * end_projected["scale"], Color(1.0, 0.95, 0.45, progress))

func _draw_energy_pulses() -> void:
	for pulse in state.energy_pulses:
		var projected: Dictionary = projector.project(pulse["sector"], pulse["lane"], state.tower_rotation, state.config.sector_count)
		if not projected["front"]:
			continue
		var progress: float = 1.0 - clampf(float(pulse["ttl"]) / float(pulse["life"]), 0.0, 1.0)
		var radius: float = lerpf(8.0, 34.0, progress) * projected["scale"]
		var alpha: float = 1.0 - progress
		draw_circle(projected["position"], radius, Color(0.45, 0.95, 1.0, alpha * projected["alpha"]))

func _draw_pulse_effects() -> void:
	for pulse in state.pulse_effects:
		var projected: Dictionary = projector.project(pulse["sector"], pulse["lane"], state.tower_rotation, state.config.sector_count)
		if not projected["front"]:
			continue
		var progress: float = 1.0 - clampf(float(pulse["ttl"]) / float(pulse["life"]), 0.0, 1.0)
		var radius: float = lerpf(22.0, 118.0, progress) * projected["scale"]
		var alpha: float = 1.0 - progress
		draw_arc(projected["position"], radius, 0.0, TAU, 48, Color(0.52, 1.0, 0.78, alpha * projected["alpha"]), 8.0)
		draw_circle(projected["position"], 18.0 * projected["scale"], Color(0.52, 1.0, 0.78, 0.32 * alpha))

func _draw_player() -> void:
	var projected: Dictionary = projector.project(state.player_sector, state.player_lane, state.tower_rotation, state.config.sector_count)
	var position: Vector2 = projected["position"]
	draw_circle(position, 30.0 * projected["scale"], Color("#f2c14e"))
	draw_circle(position + Vector2(0.0, -8.0), 10.0 * projected["scale"], Color("#101820"))
	draw_arc(position, 46.0 * projected["scale"], -0.8, 0.8, 16, Color(0.95, 0.92, 0.62, 0.45), 5.0)

func _draw_result_overlay() -> void:
	if state.run_status == "running" and state.pending_upgrade_choices.is_empty():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var alpha: float = 0.68 if state.run_status != "running" else 0.34
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.02, 0.04, 0.05, alpha))

func _draw_ellipse(center: Vector2, radius_x: float, radius_y: float, color: Color, width: float, start_angle: float, end_angle: float) -> void:
	var points := PackedVector2Array()
	var steps := 72
	for i in steps + 1:
		var t := lerpf(start_angle, end_angle, float(i) / float(steps))
		points.append(center + Vector2(cos(t) * radius_x, sin(t) * radius_y))
	draw_polyline(points, color, width)
