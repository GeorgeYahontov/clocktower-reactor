extends RefCounted
class_name GameState

const GameConfig = preload("res://scripts/data/GameConfig.gd")
const EnemyModel = preload("res://scripts/simulation/EnemyModel.gd")
const UpgradeCatalog = preload("res://scripts/data/UpgradeCatalog.gd")

var config: GameConfig
var run_time := 0.0
var tower_rotation := 0.0
var player_sector := 0
var player_lane := 1
var energy := 0
var level := 1
var reactor_integrity := 0
var max_reactor_integrity := 0
var kills := 0
var run_status := "running"
var pending_upgrade_choices: Array[Dictionary] = []
var applied_upgrades: Array[String] = []
var enemies: Array[EnemyModel] = []
var shot_traces: Array[Dictionary] = []
var energy_pulses: Array[Dictionary] = []

var _spawn_timer := 0.0
var _shot_timer := 0.0

func setup_new_run() -> void:
	config = GameConfig.new()
	run_time = 0.0
	tower_rotation = 0.0
	player_sector = 0
	player_lane = 1
	energy = 0
	level = 1
	reactor_integrity = config.reactor_integrity
	max_reactor_integrity = config.reactor_integrity
	kills = 0
	run_status = "running"
	pending_upgrade_choices.clear()
	applied_upgrades.clear()
	enemies.clear()
	shot_traces.clear()
	energy_pulses.clear()
	_spawn_timer = 0.2
	_shot_timer = 0.35

func tick(delta: float) -> void:
	if run_status != "running":
		_tick_effects(delta)
		return
	if not pending_upgrade_choices.is_empty():
		_tick_effects(delta)
		return

	run_time += delta
	_spawn_timer -= delta
	_shot_timer -= delta

	if _spawn_timer <= 0.0:
		_spawn_enemy()
		_spawn_timer = max(0.38, config.base_spawn_interval - run_time * 0.01)

	if _shot_timer <= 0.0:
		_auto_fire()
		_shot_timer = config.base_fire_interval

	for enemy in enemies:
		enemy.advance(delta, player_sector, player_lane, config.sector_count)

	_resolve_contacts()

	enemies = enemies.filter(func(enemy: EnemyModel) -> bool:
		return enemy.hp > 0
	)

	_tick_effects(delta)

	if run_time >= config.run_duration:
		run_status = "victory"

func move_player_sector(delta_sector: int) -> void:
	if run_status != "running":
		return
	player_sector = wrapi(player_sector + delta_sector, 0, config.sector_count)

func move_player_lane(delta_lane: int) -> void:
	if run_status != "running":
		return
	player_lane = clampi(player_lane + delta_lane, 0, config.lane_count - 1)

func rotate_tower(delta_rotation: float) -> void:
	if run_status != "running":
		return
	tower_rotation = wrapf(tower_rotation + delta_rotation, 0.0, float(config.sector_count))

func collect_energy(amount: int) -> void:
	energy += amount
	if energy >= config.energy_per_level:
		energy -= config.energy_per_level
		level += 1
		pending_upgrade_choices = UpgradeCatalog.pick_choices(config.upgrade_choice_count, level + kills)

func apply_upgrade(upgrade_id: String) -> void:
	for upgrade in pending_upgrade_choices:
		if upgrade["id"] != upgrade_id:
			continue
		applied_upgrades.append(upgrade_id)
		_apply_upgrade_effect(upgrade)
		pending_upgrade_choices.clear()
		return

func restart() -> void:
	setup_new_run()

func _spawn_enemy() -> void:
	var enemy := EnemyModel.new()
	var offset := randi_range(2, config.sector_count - 3)
	if randi_range(0, 1) == 0:
		offset = -offset
	enemy.sector = wrapi(player_sector + offset, 0, config.sector_count)
	enemy.lane = randi_range(0, config.lane_count - 1)
	var heavy_roll := run_time > 20.0 and randi_range(0, 4) == 0
	if heavy_roll:
		enemy.kind = "bulwark"
		enemy.hp = 5 + int(run_time / 40.0)
		enemy.speed = config.enemy_step_speed * 0.55
		enemy.reward = 2
	else:
		enemy.kind = "runner"
		enemy.hp = 2 + int(run_time / 45.0)
		enemy.speed = config.enemy_step_speed + minf(0.35, run_time / 180.0)
		enemy.reward = 1
	enemies.append(enemy)

func _auto_fire() -> void:
	if enemies.is_empty():
		return

	var target: EnemyModel = enemies[0]
	var best_score := 99999.0
	for enemy in enemies:
		var angular_distance := absf(_shortest_sector_distance(float(enemy.sector), float(player_sector)))
		var lane_distance: int = absi(enemy.lane - player_lane)
		var score := angular_distance + float(lane_distance) * config.lane_target_weight
		if score < best_score:
			best_score = score
			target = enemy

	target.hp -= 1
	shot_traces.append({
		"from_sector": player_sector,
		"from_lane": player_lane,
		"to_sector": target.sector,
		"to_lane": target.lane,
		"ttl": 0.12,
		"life": 0.12
	})
	if target.hp <= 0:
		kills += 1
		energy_pulses.append({
			"sector": target.sector,
			"lane": target.lane,
			"ttl": 0.42,
			"life": 0.42
		})
		collect_energy(target.reward + _energy_bonus())

func _shortest_sector_distance(a: float, b: float) -> float:
	var half: float = float(config.sector_count) * 0.5
	return wrapf(a - b + half, 0.0, float(config.sector_count)) - half

func _resolve_contacts() -> void:
	for enemy in enemies:
		if enemy.sector == player_sector and enemy.lane == player_lane:
			enemy.hp = 0
			reactor_integrity -= config.enemy_contact_damage
			if reactor_integrity <= 0:
				run_status = "defeat"

func _tick_effects(delta: float) -> void:
	for trace in shot_traces:
		trace["ttl"] = float(trace["ttl"]) - delta
	shot_traces = shot_traces.filter(func(trace: Dictionary) -> bool:
		return float(trace["ttl"]) > 0.0
	)

	for pulse in energy_pulses:
		pulse["ttl"] = float(pulse["ttl"]) - delta
	energy_pulses = energy_pulses.filter(func(pulse: Dictionary) -> bool:
		return float(pulse["ttl"]) > 0.0
	)

func _apply_upgrade_effect(upgrade: Dictionary) -> void:
	match upgrade["stat"]:
		"fire_interval":
			config.base_fire_interval = maxf(0.12, config.base_fire_interval + float(upgrade["value"]))
		"lane_weight":
			config.lane_target_weight = maxf(0.55, config.lane_target_weight + float(upgrade["value"]))
		"integrity":
			reactor_integrity = mini(max_reactor_integrity, reactor_integrity + int(upgrade["value"]))
		"energy_bonus":
			pass
		"rotation_speed":
			config.manual_rotation_speed += float(upgrade["value"])
			config.drag_rotation_sensitivity += 0.002
		"max_integrity":
			max_reactor_integrity += int(upgrade["value"])
			reactor_integrity += int(upgrade["value"])

func _energy_bonus() -> int:
	var bonus := 0
	for upgrade_id in applied_upgrades:
		if upgrade_id == "charged_cells":
			bonus += 1
	return bonus
