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
	_draw_vents()
	_draw_energy_pulses()
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

func _draw_vents() -> void:
	for vent in state.vents:
		var projected: Dictionary = projector.project(vent.sector, vent.lane, state.tower_rotation, state.config.sector_count)
		if not projected["front"]:
			continue
		var urgency: float = vent.urgency()
		var radius: float = lerpf(16.0, 32.0, urgency) * projected["scale"]
		var color := Color(0.85, 0.22, 1.0, projected["alpha"])
		var warning := Color(1.0, 0.92, 0.24, projected["alpha"])
		draw_circle(projected["position"], radius, Color(color.r, color.g, color.b, 0.25 * projected["alpha"]))
		draw_arc(projected["position"], radius, 0.0, TAU * maxf(0.05, vent.ttl / vent.life), 28, warning, 4.0)
		draw_line(projected["position"] + Vector2(-radius * 0.55, 0.0), projected["position"] + Vector2(radius * 0.55, 0.0), color, 4.0)
		draw_line(projected["position"] + Vector2(0.0, -radius * 0.55), projected["position"] + Vector2(0.0, radius * 0.55), color, 4.0)
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
		if enemy.kind == "bulwark":
			var bulwark_size: Vector2 = Vector2(42.0, 52.0) * projected["scale"]
			var bulwark_pos: Vector2 = projected["position"] - bulwark_size * 0.5
			draw_rect(Rect2(bulwark_pos, bulwark_size), Color(0.46, 0.62, 0.82, projected["alpha"]), true, 5.0)
			draw_rect(Rect2(bulwark_pos, bulwark_size), Color(0.82, 0.96, 1.0, projected["alpha"]), false, 3.0)
		else:
			draw_rect(Rect2(pos, size), Color(0.89, 0.34, 0.18, projected["alpha"]), true, 4.0)
			draw_rect(Rect2(pos, size), Color(1.0, 0.84, 0.32, projected["alpha"]), false, 2.0)

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
	draw_circle(position, 28.0 * projected["scale"], Color("#f2c14e"))
	draw_circle(position + Vector2(0.0, -8.0), 10.0 * projected["scale"], Color("#101820"))
	draw_arc(position, 42.0 * projected["scale"], -0.8, 0.8, 16, Color(0.95, 0.92, 0.62, 0.45), 5.0)

func _draw_result_overlay() -> void:
	if state.run_status == "running" and state.pending_upgrade_choices.is_empty():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var alpha: float = 0.68 if state.run_status != "running" else 0.34
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.02, 0.04, 0.05, alpha))
