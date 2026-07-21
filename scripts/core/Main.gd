extends Node2D

const GameState = preload("res://scripts/simulation/GameState.gd")

@onready var tower_renderer: Node2D = $TowerRenderer
@onready var hud: CanvasLayer = $Hud

var game_state: GameState
var _touch_dragging := false

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

func _unhandled_input(event: InputEvent) -> void:
	if game_state == null:
		return

	if event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		_touch_dragging = true
		game_state.rotate_tower(-drag_event.relative.x * game_state.config.drag_rotation_sensitivity)

	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_touch_dragging = false
		elif not _touch_dragging and touch_event.position.y > get_viewport_rect().size.y * 0.68:
			if touch_event.position.x < get_viewport_rect().size.x * 0.5:
				game_state.move_player_lane(-1)
			else:
				game_state.move_player_lane(1)

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
