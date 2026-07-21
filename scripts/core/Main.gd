extends Node2D

const GameState = preload("res://scripts/simulation/GameState.gd")

@onready var tower_renderer: Node2D = $TowerRenderer
@onready var hud: CanvasLayer = $Hud

var game_state: GameState
var _touch_dragging := false
var _mouse_dragging := false
var _mouse_drag_distance := 0.0

func _ready() -> void:
	game_state = GameState.new()
	game_state.setup_new_run()
	tower_renderer.bind(game_state)
	hud.bind(game_state)
	hud.upgrade_selected.connect(_on_upgrade_selected)
	hud.restart_requested.connect(_on_restart_requested)

func _process(delta: float) -> void:
	_handle_preview_input(delta)
	game_state.tick(delta)
	tower_renderer.queue_redraw()
	hud.refresh()

func _unhandled_input(event: InputEvent) -> void:
	if game_state == null:
		return
	if not game_state.pending_upgrade_choices.is_empty():
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
				game_state.move_player_sector(-1)
			else:
				game_state.move_player_sector(1)
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if button_event.pressed:
			_mouse_dragging = true
			_mouse_drag_distance = 0.0
		else:
			_mouse_dragging = false
			if _mouse_drag_distance < 12.0 and button_event.position.y > get_viewport_rect().size.y * 0.68:
				if button_event.position.x < get_viewport_rect().size.x * 0.5:
					game_state.move_player_sector(-1)
				else:
					game_state.move_player_sector(1)

	if event is InputEventMouseMotion:
		var motion_event := event as InputEventMouseMotion
		if _mouse_dragging:
			_mouse_drag_distance += absf(motion_event.relative.x)
			game_state.rotate_tower(-motion_event.relative.x * game_state.config.drag_rotation_sensitivity)

func _handle_preview_input(delta: float) -> void:
	var sector_delta := 0
	if Input.is_action_just_pressed("move_left"):
		sector_delta -= 1
	if Input.is_action_just_pressed("move_right"):
		sector_delta += 1
	if sector_delta != 0:
		game_state.move_player_sector(sector_delta)

	var lane_delta := 0
	if Input.is_action_just_pressed("move_up"):
		lane_delta += 1
	if Input.is_action_just_pressed("move_down"):
		lane_delta -= 1
	if lane_delta != 0:
		game_state.move_player_lane(lane_delta)

	var rotation := 0.0
	if Input.is_action_pressed("rotate_left"):
		rotation -= 1.0
	if Input.is_action_pressed("rotate_right"):
		rotation += 1.0
	if rotation != 0.0:
		game_state.rotate_tower(rotation * delta * game_state.config.manual_rotation_speed)

func _on_upgrade_selected(upgrade_id: String) -> void:
	game_state.apply_upgrade(upgrade_id)

func _on_restart_requested() -> void:
	game_state.restart()
