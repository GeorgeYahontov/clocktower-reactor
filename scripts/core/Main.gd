extends Node2D

const GameState = preload("res://scripts/simulation/GameState.gd")

@onready var tower_renderer: Node2D = $TowerRenderer
@onready var hud: CanvasLayer = $Hud

var game_state: GameState

func _ready() -> void:
	game_state = GameState.new()
	game_state.setup_new_run()
	tower_renderer.bind(game_state)
	hud.bind(game_state)

func _process(delta: float) -> void:
	_handle_preview_input(delta)
	game_state.tick(delta)
	tower_renderer.queue_redraw()
	hud.refresh()

func _handle_preview_input(delta: float) -> void:
	var lane_delta := 0
	if Input.is_action_just_pressed("move_left"):
		lane_delta -= 1
	if Input.is_action_just_pressed("move_right"):
		lane_delta += 1
	if lane_delta != 0:
		game_state.move_player_lane(lane_delta)

	var rotation := 0.0
	if Input.is_action_pressed("rotate_left"):
		rotation -= 1.0
	if Input.is_action_pressed("rotate_right"):
		rotation += 1.0
	if rotation != 0.0:
		game_state.rotate_tower(rotation * delta * game_state.config.manual_rotation_speed)
