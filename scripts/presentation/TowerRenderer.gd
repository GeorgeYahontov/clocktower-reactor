extends Node2D

var state: RefCounted

const BELT_RECT := Rect2(Vector2(78.0, 256.0), Vector2(564.0, 650.0))
const LANE_HEIGHT := 178.0
const SECTOR_WIDTH := 86.0
const FRONT_X := 360.0

func bind(game_state: RefCounted) -> void:
	state = game_state

func _draw() -> void:
	if state == null:
		return

	_draw_background()
	_draw_touch_zones()
	_draw_reactor_status_glow()
	_draw_reactor_belt()
	_draw_belt_grid()
	_draw_energy_pulses()
	_draw_pulse_effects()
	_draw_event_flashes()
	_draw_shot_traces()
	_draw_vents()
	_draw_enemies()
	_draw_player()
	_draw_radar()
	_draw_result_overlay()

func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#101820"))
	for i in 10:
		var y: float = 120.0 + float(i) * 104.0
		draw_line(Vector2(0.0, y), Vector2(720.0, y + 26.0), Color(0.10, 0.16, 0.18, 0.30), 2.0)

func _draw_touch_zones() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var zone_top: float = viewport_size.y * 0.70
	_draw_touch_zone(Rect2(Vector2(18.0, zone_top), Vector2(132.0, 164.0)), -1)
	_draw_touch_zone(Rect2(Vector2(viewport_size.x - 150.0, zone_top), Vector2(132.0, 164.0)), 1)

func _draw_touch_zone(rect: Rect2, direction: int) -> void:
	draw_rect(rect, Color(0.08, 0.15, 0.16, 0.24), true)
	draw_rect(rect, Color(0.42, 0.78, 0.76, 0.25), false, 2.0)
	var center: Vector2 = rect.get_center()
	var arrow_width: float = 28.0 * float(direction)
	var points := PackedVector2Array([
		center + Vector2(arrow_width, 0.0),
		center + Vector2(-arrow_width * 0.45, -30.0),
		center + Vector2(-arrow_width * 0.45, 30.0)
	])
	draw_colored_polygon(points, Color(0.72, 0.96, 0.92, 0.34))

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

func _draw_reactor_belt() -> void:
	draw_rect(BELT_RECT.grow(14.0), Color(0.03, 0.06, 0.07, 0.70), true)
	draw_rect(BELT_RECT.grow(14.0), Color(0.30, 0.56, 0.58, 0.52), false, 4.0)
	draw_rect(BELT_RECT, Color(0.07, 0.12, 0.13, 0.88), true)
	for lane in state.config.lane_count:
		var lane_rect: Rect2 = _lane_rect(lane)
		var fill := Color(0.09, 0.16, 0.17, 0.82) if lane % 2 == 0 else Color(0.06, 0.12, 0.13, 0.86)
		draw_rect(lane_rect, fill, true)
		draw_rect(lane_rect, Color(0.31, 0.58, 0.58, 0.42), false, 2.0)

	_draw_center_reactor_core()
	draw_line(Vector2(FRONT_X, BELT_RECT.position.y - 20.0), Vector2(FRONT_X, BELT_RECT.end.y + 20.0), Color(0.95, 0.78, 0.28, 0.62), 5.0)
	draw_line(Vector2(BELT_RECT.position.x, BELT_RECT.position.y - 16.0), Vector2(BELT_RECT.end.x, BELT_RECT.position.y - 16.0), Color(0.42, 0.78, 0.76, 0.34), 3.0)
	draw_line(Vector2(BELT_RECT.position.x, BELT_RECT.end.y + 16.0), Vector2(BELT_RECT.end.x, BELT_RECT.end.y + 16.0), Color(0.42, 0.78, 0.76, 0.34), 3.0)

func _draw_center_reactor_core() -> void:
	var top: Vector2 = Vector2(FRONT_X, BELT_RECT.position.y + 30.0)
	var bottom: Vector2 = Vector2(FRONT_X, BELT_RECT.end.y - 30.0)
	draw_line(top, bottom, Color(0.42, 0.95, 1.0, 0.16), 22.0)
	draw_line(top, bottom, Color(0.82, 1.0, 1.0, 0.48), 4.0)
	for y in [340.0, 506.0, 672.0, 838.0]:
		draw_arc(Vector2(FRONT_X, y), 38.0, 0.0, TAU, 48, Color(0.58, 0.96, 1.0, 0.24), 2.0)

func _draw_belt_grid() -> void:
	for lane in state.config.lane_count:
		for marker in state.config.sector_count:
			var projected: Dictionary = _project_belt(marker, lane)
			if not projected["visible"]:
				continue
			var pos: Vector2 = projected["position"]
			var alpha: float = projected["alpha"]
			var lane_rect: Rect2 = _lane_rect(lane)
			draw_line(Vector2(pos.x, lane_rect.position.y + 16.0), Vector2(pos.x, lane_rect.end.y - 16.0), Color(0.35, 0.58, 0.58, 0.18 * alpha), 2.0)
			draw_circle(pos, 5.0, Color(0.38, 0.62, 0.62, 0.32 * alpha))
			_draw_surface_tick(pos, alpha)

func _draw_surface_tick(pos: Vector2, alpha: float) -> void:
	draw_line(pos + Vector2(-12.0, -8.0), pos + Vector2(12.0, 8.0), Color(0.72, 0.95, 0.92, 0.38 * alpha), 2.0)

func _draw_vents() -> void:
	for vent in state.vents:
		var projected: Dictionary = _project_belt(vent.sector, vent.lane)
		if not projected["visible"]:
			continue
		var pos: Vector2 = projected["position"]
		var urgency: float = vent.urgency()
		var radius: float = lerpf(18.0, 34.0, urgency)
		var color := Color(0.88, 0.18, 1.0, projected["alpha"])
		draw_circle(pos, radius, Color(color.r, color.g, color.b, 0.25 * projected["alpha"]))
		draw_arc(pos, radius, -PI * 0.5, -PI * 0.5 + TAU * maxf(0.05, vent.ttl / vent.life), 32, Color(1.0, 0.92, 0.24, projected["alpha"]), 5.0)
		draw_line(pos + Vector2(0.0, -radius * 0.48), pos + Vector2(0.0, radius * 0.12), color, 5.0)
		draw_circle(pos + Vector2(0.0, radius * 0.48), 3.5, color)

func _draw_enemies() -> void:
	for enemy in state.enemies:
		var projected: Dictionary = _project_belt(enemy.sector, enemy.lane)
		if not projected["visible"]:
			continue
		if enemy.kind == "bulwark":
			_draw_bulwark(projected)
		else:
			_draw_runner(projected)

func _draw_runner(projected: Dictionary) -> void:
	var size := Vector2(34.0, 48.0)
	var pos: Vector2 = projected["position"] - size * 0.5
	draw_rect(Rect2(pos, size), Color(0.89, 0.34, 0.18, projected["alpha"]), true, 4.0)
	draw_rect(Rect2(pos, size), Color(1.0, 0.84, 0.32, projected["alpha"]), false, 2.0)
	draw_line(projected["position"] + Vector2(-9.0, -5.0), projected["position"] + Vector2(9.0, -5.0), Color(0.10, 0.06, 0.04, projected["alpha"]), 3.0)

func _draw_bulwark(projected: Dictionary) -> void:
	var center: Vector2 = projected["position"]
	var points := PackedVector2Array([
		center + Vector2(0.0, -38.0),
		center + Vector2(30.0, -18.0),
		center + Vector2(24.0, 26.0),
		center + Vector2(0.0, 40.0),
		center + Vector2(-24.0, 26.0),
		center + Vector2(-30.0, -18.0)
	])
	draw_colored_polygon(points, Color(0.35, 0.58, 0.86, projected["alpha"]))
	draw_polyline(points, Color(0.82, 0.96, 1.0, projected["alpha"]), 3.0, true)
	draw_circle(center, 9.0, Color(0.08, 0.18, 0.28, projected["alpha"]))
	draw_line(center + Vector2(-14.0, -3.0), center + Vector2(14.0, -3.0), Color(0.82, 0.96, 1.0, projected["alpha"]), 3.0)

func _draw_player() -> void:
	var projected: Dictionary = _project_belt(state.player_sector, state.player_lane)
	var position: Vector2 = projected["position"]
	draw_circle(position, 31.0, Color("#f2c14e"))
	draw_circle(position + Vector2(0.0, -8.0), 10.0, Color("#101820"))
	draw_arc(position, 48.0, -0.8, 0.8, 16, Color(0.95, 0.92, 0.62, 0.45), 5.0)

func _draw_shot_traces() -> void:
	for trace in state.shot_traces:
		var start_projected: Dictionary = _project_belt(trace["from_sector"], trace["from_lane"])
		var end_projected: Dictionary = _project_belt(trace["to_sector"], trace["to_lane"])
		if not start_projected["visible"] or not end_projected["visible"]:
			continue
		var progress: float = clampf(float(trace["ttl"]) / float(trace["life"]), 0.0, 1.0)
		draw_line(start_projected["position"], end_projected["position"], Color(0.45, 0.95, 1.0, progress), 5.0)
		draw_circle(end_projected["position"], 12.0, Color(1.0, 0.95, 0.45, progress))

func _draw_energy_pulses() -> void:
	for pulse in state.energy_pulses:
		var projected: Dictionary = _project_belt(pulse["sector"], pulse["lane"])
		if not projected["visible"]:
			continue
		var progress: float = 1.0 - clampf(float(pulse["ttl"]) / float(pulse["life"]), 0.0, 1.0)
		var radius: float = lerpf(8.0, 34.0, progress)
		var alpha: float = 1.0 - progress
		draw_circle(projected["position"], radius, Color(0.45, 0.95, 1.0, alpha * projected["alpha"]))

func _draw_pulse_effects() -> void:
	for pulse in state.pulse_effects:
		var projected: Dictionary = _project_belt(pulse["sector"], pulse["lane"])
		if not projected["visible"]:
			continue
		var progress: float = 1.0 - clampf(float(pulse["ttl"]) / float(pulse["life"]), 0.0, 1.0)
		var radius: float = lerpf(22.0, 118.0, progress)
		var alpha: float = 1.0 - progress
		draw_arc(projected["position"], radius, 0.0, TAU, 48, Color(0.52, 1.0, 0.78, alpha * projected["alpha"]), 8.0)
		draw_circle(projected["position"], 18.0, Color(0.52, 1.0, 0.78, 0.32 * alpha))

func _draw_event_flashes() -> void:
	for flash in state.event_flashes:
		var projected: Dictionary = _project_belt(int(flash["sector"]), int(flash["lane"]))
		if not projected["visible"]:
			continue
		var progress: float = 1.0 - clampf(float(flash["ttl"]) / float(flash["life"]), 0.0, 1.0)
		var alpha: float = 1.0 - progress
		var radius: float = lerpf(20.0, 86.0, progress)
		var color := Color(0.95, 0.20, 0.14, alpha * projected["alpha"])
		if String(flash["kind"]) == "repair":
			color = Color(0.35, 1.0, 0.68, alpha * projected["alpha"])
		elif String(flash["kind"]) == "upgrade":
			color = Color(0.95, 0.78, 0.28, alpha * projected["alpha"])
		draw_arc(projected["position"], radius, 0.0, TAU, 48, color, 7.0)
		draw_circle(projected["position"], 14.0, Color(color.r, color.g, color.b, 0.24 * alpha))

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

func _draw_result_overlay() -> void:
	if state.run_status == "running":
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.02, 0.04, 0.05, 0.68))

func _project_belt(sector: int, lane: int) -> Dictionary:
	var offset: float = _shortest_sector_distance(float(sector), state.tower_rotation)
	var x: float = FRONT_X + offset * SECTOR_WIDTH
	var lane_rect: Rect2 = _lane_rect(lane)
	var y: float = lane_rect.get_center().y
	var edge_fade: float = clampf(1.0 - maxf(0.0, absf(x - FRONT_X) - 190.0) / 120.0, 0.0, 1.0)
	return {
		"position": Vector2(x, y),
		"alpha": lerpf(0.28, 1.0, edge_fade),
		"visible": x > BELT_RECT.position.x - 44.0 and x < BELT_RECT.end.x + 44.0
	}

func _lane_rect(lane: int) -> Rect2:
	var visual_lane: int = state.config.lane_count - 1 - lane
	var top: float = BELT_RECT.position.y + 46.0 + float(visual_lane) * LANE_HEIGHT
	return Rect2(Vector2(BELT_RECT.position.x + 18.0, top), Vector2(BELT_RECT.size.x - 36.0, LANE_HEIGHT - 20.0))

func _radar_position(center: Vector2, radius: float, sector: int, lane: int, sector_count: int) -> Vector2:
	var angle := _radar_angle(sector, sector_count)
	var lane_ratio := 0.42 + (float(lane) / maxf(1.0, float(state.config.lane_count - 1))) * 0.48
	return center + Vector2(cos(angle), sin(angle)) * radius * lane_ratio

func _radar_angle(sector: int, sector_count: int) -> float:
	return ((float(sector) - state.tower_rotation) / float(sector_count)) * TAU - PI * 0.5

func _shortest_sector_distance(a: float, b: float) -> float:
	var half: float = float(state.config.sector_count) * 0.5
	return wrapf(a - b + half, 0.0, float(state.config.sector_count)) - half