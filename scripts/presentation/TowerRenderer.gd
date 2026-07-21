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
	_draw_touch_zones()
	_draw_reactor_status_glow()
	_draw_tower_shell()
	_draw_front_work_zone()
	_draw_lane_rings()
	_draw_rotation_ticks()
	_draw_sector_guides()
	_draw_grid_points()
	_draw_rotation_seam()
	_draw_vents()
	_draw_energy_pulses()
	_draw_pulse_effects()
	_draw_event_flashes()
	_draw_shot_traces()
	_draw_enemies()
	_draw_player()
	_draw_radar()
	_draw_result_overlay()

func _draw_touch_zones() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var zone_top := viewport_size.y * 0.70
	var zone_height := 164.0
	var left_rect := Rect2(Vector2(18.0, zone_top), Vector2(132.0, zone_height))
	var right_rect := Rect2(Vector2(viewport_size.x - 150.0, zone_top), Vector2(132.0, zone_height))
	_draw_touch_zone(left_rect, -1)
	_draw_touch_zone(right_rect, 1)

func _draw_touch_zone(rect: Rect2, direction: int) -> void:
	var fill := Color(0.10, 0.18, 0.19, 0.32)
	var border := Color(0.42, 0.78, 0.76, 0.34)
	draw_rect(rect, fill, true)
	draw_rect(rect, border, false, 3.0)
	var center := rect.get_center()
	var arrow_width := 28.0 * float(direction)
	var points := PackedVector2Array([
		center + Vector2(arrow_width, 0.0),
		center + Vector2(-arrow_width * 0.45, -30.0),
		center + Vector2(-arrow_width * 0.45, 30.0)
	])
	draw_colored_polygon(points, Color(0.72, 0.96, 0.92, 0.42))
func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#101820"))
	for i in 12:
		var y := 90.0 + float(i) * 92.0
		draw_line(Vector2(0.0, y), Vector2(720.0, y + 32.0), Color(0.12, 0.18, 0.21, 0.28), 2.0)

func _draw_reactor_status_glow() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var integrity_ratio: float = float(state.reactor_integrity) / maxf(1.0, float(state.max_reactor_integrity))
	if integrity_ratio <= 0.42 and state.run_status == "running":
		var danger_alpha: float = lerpf(0.08, 0.22, 1.0 - integrity_ratio)
		draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.95, 0.12, 0.10, danger_alpha))
		draw_rect(Rect2(Vector2(8.0, 8.0), viewport_size - Vector2(16.0, 16.0)), Color(1.0, 0.18, 0.12, 0.40), false, 8.0)

	if not state.pending_upgrade_choices.is_empty() and state.run_status == "running":
		var panel_rect := Rect2(Vector2(0.0, 1088.0), Vector2(viewport_size.x, 192.0))
		draw_rect(panel_rect, Color(0.95, 0.72, 0.24, 0.11))
		draw_line(Vector2(34.0, 1114.0), Vector2(viewport_size.x - 34.0, 1114.0), Color(0.95, 0.82, 0.36, 0.34), 3.0)
func _draw_tower_shell() -> void:
	var center: Vector2 = projector.center
	var top_center := Vector2(center.x, 330.0)
	var bottom_center := Vector2(center.x, 885.0)
	_draw_ellipse(top_center, projector.radius_x, 62.0, Color(0.26, 0.42, 0.44, 0.55), 5.0, 0.0, TAU)
	_draw_ellipse(bottom_center, projector.radius_x, 76.0, Color(0.18, 0.30, 0.32, 0.72), 6.0, 0.0, TAU)
	draw_line(Vector2(center.x - projector.radius_x, top_center.y), Vector2(center.x - projector.radius_x, bottom_center.y), Color(0.18, 0.30, 0.32, 0.65), 4.0)
	draw_line(Vector2(center.x + projector.radius_x, top_center.y), Vector2(center.x + projector.radius_x, bottom_center.y), Color(0.18, 0.30, 0.32, 0.65), 4.0)
	draw_line(Vector2(center.x, top_center.y - 42.0), Vector2(center.x, bottom_center.y + 34.0), Color(0.43, 0.95, 1.0, 0.32), 18.0)
	draw_line(Vector2(center.x, top_center.y - 42.0), Vector2(center.x, bottom_center.y + 34.0), Color(0.82, 1.0, 1.0, 0.72), 5.0)
	for y in [380.0, 508.0, 636.0, 764.0]:
		_draw_ellipse(Vector2(center.x, y), 42.0, 13.0, Color(0.56, 0.94, 1.0, 0.36), 3.0, 0.0, TAU)
	_draw_ellipse(Vector2(center.x, 610.0), projector.radius_x + 18.0, 92.0, Color(0.92, 0.82, 0.36, 0.18), 8.0, 0.0, TAU)

func _draw_front_work_zone() -> void:
	var left_bottom: Dictionary = _project_surface(state.tower_rotation - 0.85, 0)
	var right_bottom: Dictionary = _project_surface(state.tower_rotation + 0.85, 0)
	var right_top: Dictionary = _project_surface(state.tower_rotation + 0.85, state.config.lane_count - 1)
	var left_top: Dictionary = _project_surface(state.tower_rotation - 0.85, state.config.lane_count - 1)
	var points := PackedVector2Array([left_bottom["position"], right_bottom["position"], right_top["position"], left_top["position"]])
	draw_colored_polygon(points, Color(0.95, 0.78, 0.28, 0.08))
	draw_polyline(points, Color(0.95, 0.82, 0.36, 0.34), 2.0, true)

func _draw_rotation_ticks() -> void:
	for lane in state.config.lane_count:
		for marker in state.config.sector_count * 2:
			var sector_value: float = float(marker) * 0.5
			var projected: Dictionary = _project_surface(sector_value, lane)
			if not projected["front"]:
				continue
			var pos: Vector2 = projected["position"]
			var scale: float = projected["scale"]
			var alpha: float = 0.22 + 0.42 * projected["alpha"]
			var long_tick: bool = marker % 2 == 0
			var half: float = 13.0 if long_tick else 7.0
			var width: float = 3.0 if long_tick else 2.0
			draw_line(pos + Vector2(-half, -5.0) * scale, pos + Vector2(half, 5.0) * scale, Color(0.74, 0.95, 0.92, alpha), width)

func _draw_rotation_seam() -> void:
	var bottom: Dictionary = _project_surface(0.0, 0)
	var top: Dictionary = _project_surface(0.0, state.config.lane_count - 1)
	if not bottom["front"] and not top["front"]:
		return
	var alpha: float = 0.32 + 0.42 * maxf(bottom["alpha"], top["alpha"])
	draw_line(bottom["position"], top["position"], Color(0.95, 0.82, 0.32, alpha), 5.0)
	draw_circle(top["position"], 9.0 * top["scale"], Color(0.95, 0.82, 0.32, alpha))
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

func _draw_event_flashes() -> void:
	for flash in state.event_flashes:
		var projected: Dictionary = projector.project(int(flash["sector"]), int(flash["lane"]), state.tower_rotation, state.config.sector_count)
		if not projected["front"]:
			continue
		var progress: float = 1.0 - clampf(float(flash["ttl"]) / float(flash["life"]), 0.0, 1.0)
		var alpha: float = 1.0 - progress
		var radius: float = lerpf(20.0, 86.0, progress) * projected["scale"]
		var color := Color(0.95, 0.20, 0.14, alpha * projected["alpha"])
		if String(flash["kind"]) == "repair":
			color = Color(0.35, 1.0, 0.68, alpha * projected["alpha"])
		elif String(flash["kind"]) == "upgrade":
			color = Color(0.95, 0.78, 0.28, alpha * projected["alpha"])
		draw_arc(projected["position"], radius, 0.0, TAU, 48, color, 7.0)
		draw_circle(projected["position"], 14.0 * projected["scale"], Color(color.r, color.g, color.b, 0.24 * alpha))
func _draw_player() -> void:
	var projected: Dictionary = projector.project(state.player_sector, state.player_lane, state.tower_rotation, state.config.sector_count)
	var position: Vector2 = projected["position"]
	draw_circle(position, 30.0 * projected["scale"], Color("#f2c14e"))
	draw_circle(position + Vector2(0.0, -8.0), 10.0 * projected["scale"], Color("#101820"))
	draw_arc(position, 46.0 * projected["scale"], -0.8, 0.8, 16, Color(0.95, 0.92, 0.62, 0.45), 5.0)

func _draw_radar() -> void:
	var sector_count: int = state.config.sector_count
	var center := Vector2(612.0, 560.0)
	var radius := 58.0
	draw_circle(center, radius + 12.0, Color(0.04, 0.08, 0.09, 0.72))
	draw_arc(center, radius, 0.0, TAU, 72, Color(0.38, 0.66, 0.66, 0.72), 3.0)
	draw_arc(center, radius * 0.58, 0.0, TAU, 72, Color(0.26, 0.45, 0.45, 0.42), 2.0)
	draw_line(center + Vector2(0.0, -radius - 8.0), center + Vector2(0.0, -radius + 10.0), Color(0.95, 0.86, 0.38, 0.95), 4.0)
	for sector in sector_count:
		var sector_angle := _radar_angle(sector, sector_count)
		var edge := center + Vector2(cos(sector_angle), sin(sector_angle)) * radius
		draw_line(center + (edge - center).normalized() * (radius - 7.0), edge, Color(0.35, 0.56, 0.56, 0.35), 1.0)

	for vent in state.vents:
		var pos := _radar_position(center, radius, vent.sector, vent.lane, sector_count)
		draw_circle(pos, 5.5, Color(0.90, 0.18, 1.0, 0.95))
		draw_circle(pos, 8.0, Color(0.90, 0.18, 1.0, 0.22))

	for enemy in state.enemies:
		var pos := _radar_position(center, radius, enemy.sector, enemy.lane, sector_count)
		var color := Color(0.35, 0.58, 0.86, 0.95) if enemy.kind == "bulwark" else Color(0.92, 0.36, 0.18, 0.95)
		draw_circle(pos, 4.2, color)

	var player_pos := _radar_position(center, radius, state.player_sector, state.player_lane, sector_count)
	draw_circle(player_pos, 7.0, Color(0.95, 0.76, 0.31, 1.0))
	draw_circle(player_pos, 10.0, Color(0.95, 0.76, 0.31, 0.22))

func _radar_position(center: Vector2, radius: float, sector: int, lane: int, sector_count: int) -> Vector2:
	var angle := _radar_angle(sector, sector_count)
	var lane_ratio := 0.42 + (float(lane) / maxf(1.0, float(state.config.lane_count - 1))) * 0.48
	return center + Vector2(cos(angle), sin(angle)) * radius * lane_ratio

func _radar_angle(sector: int, sector_count: int) -> float:
	return ((float(sector) - state.tower_rotation) / float(sector_count)) * TAU - PI * 0.5
func _draw_result_overlay() -> void:
	if state.run_status == "running":
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var alpha: float = 0.68 if state.run_status != "running" else 0.34
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.02, 0.04, 0.05, alpha))

func _project_surface(sector_value: float, lane: int) -> Dictionary:
	var angle: float = ((sector_value - state.tower_rotation) / float(state.config.sector_count)) * TAU
	var side: float = sin(angle)
	var depth: float = cos(angle)
	var x: float = projector.center.x + side * projector.radius_x
	var y: float = projector.center.y + projector.base_y - float(lane) * projector.lane_y - depth * 36.0
	var scale: float = lerpf(0.62, 1.18, (depth + 1.0) * 0.5)
	var alpha: float = lerpf(0.18, 1.0, (depth + 1.0) * 0.5)
	return {
		"position": Vector2(x, y),
		"scale": scale,
		"alpha": alpha,
		"depth": depth,
		"front": depth > -0.15
	}
func _draw_ellipse(center: Vector2, radius_x: float, radius_y: float, color: Color, width: float, start_angle: float, end_angle: float) -> void:
	var points := PackedVector2Array()
	var steps := 72
	for i in steps + 1:
		var t := lerpf(start_angle, end_angle, float(i) / float(steps))
		points.append(center + Vector2(cos(t) * radius_x, sin(t) * radius_y))
	draw_polyline(points, color, width)
