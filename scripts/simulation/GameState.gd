extends RefCounted
class_name GameState

const GameConfig = preload("res://scripts/data/GameConfig.gd")
const EnemyModel = preload("res://scripts/simulation/EnemyModel.gd")

var config: GameConfig
var run_time := 0.0
var tower_rotation := 0.0
var player_sector := 0
var player_lane := 1
var energy := 0
var level := 1
var enemies: Array[EnemyModel] = []

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
	enemies.clear()
	_spawn_timer = 0.2
	_shot_timer = 0.35

func tick(delta: float) -> void:
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

	enemies = enemies.filter(func(enemy: EnemyModel) -> bool:
		return enemy.hp > 0
	)

func move_player_lane(delta_lane: int) -> void:
	player_lane = clampi(player_lane + delta_lane, 0, config.lane_count - 1)

func rotate_tower(delta_rotation: float) -> void:
	tower_rotation = wrapf(tower_rotation + delta_rotation, 0.0, float(config.sector_count))

func collect_energy(amount: int) -> void:
	energy += amount
	if energy >= config.energy_per_level:
		energy -= config.energy_per_level
		level += 1

func _spawn_enemy() -> void:
	var enemy := EnemyModel.new()
	enemy.sector = randi_range(2, config.sector_count - 3)
	enemy.lane = randi_range(0, config.lane_count - 1)
	enemy.hp = 2 + int(run_time / 45.0)
	enemy.speed = config.enemy_step_speed
	enemies.append(enemy)

func _auto_fire() -> void:
	if enemies.is_empty():
		return

	var target: EnemyModel = enemies[0]
	var best_score := 99999.0
	for enemy in enemies:
		var angular_distance := absf(_shortest_sector_distance(float(enemy.sector), float(player_sector)))
		var lane_distance: int = absi(enemy.lane - player_lane)
		var score := angular_distance + float(lane_distance) * 1.35
		if score < best_score:
			best_score = score
			target = enemy

	target.hp -= 1
	if target.hp <= 0:
		collect_energy(1)

func _shortest_sector_distance(a: float, b: float) -> float:
	var half: float = float(config.sector_count) * 0.5
	return wrapf(a - b + half, 0.0, float(config.sector_count)) - half
