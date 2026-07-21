extends CanvasLayer

signal upgrade_selected(upgrade_id: String)
signal restart_requested

var state
var label: Label
var tutorial: Label
var controls_legend: Label
var upgrade_panel: VBoxContainer
var restart_button: Button

func bind(game_state) -> void:
	state = game_state
	label = Label.new()
	label.position = Vector2(24.0, 24.0)
	label.add_theme_font_size_override("font_size", 25)
	add_child(label)

	controls_legend = Label.new()
	controls_legend.position = Vector2(382.0, 24.0)
	controls_legend.size = Vector2(314.0, 190.0)
	controls_legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_legend.add_theme_font_size_override("font_size", 20)
	controls_legend.text = "Управление\nA/D: дорожка\nQ/E: вращать башню\nТач: свайп - вращать\nНиз экрана: влево/вправо"
	add_child(controls_legend)

	tutorial = Label.new()
	tutorial.position = Vector2(24.0, 1090.0)
	tutorial.size = Vector2(672.0, 150.0)
	tutorial.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial.add_theme_font_size_override("font_size", 25)
	add_child(tutorial)

	upgrade_panel = VBoxContainer.new()
	upgrade_panel.position = Vector2(42.0, 735.0)
	upgrade_panel.size = Vector2(636.0, 285.0)
	upgrade_panel.visible = false
	add_child(upgrade_panel)

	restart_button = Button.new()
	restart_button.text = "Начать заново"
	restart_button.position = Vector2(250.0, 1010.0)
	restart_button.size = Vector2(220.0, 64.0)
	restart_button.visible = false
	restart_button.pressed.connect(func() -> void:
		restart_requested.emit()
	)
	add_child(restart_button)
	refresh()

func refresh() -> void:
	if state == null or label == null:
		return
	var time_left: float = maxf(0.0, state.config.run_duration - state.run_time)
	label.text = "Clocktower Reactor\nВремя: %.0f\nУровень: %d\nЭнергия: %d/%d\nРеактор: %d\nУбийства: %d" % [
		time_left,
		state.level,
		state.energy,
		state.config.energy_per_level,
		state.reactor_integrity,
		state.kills
	]

	if tutorial == null:
		return
	if state.run_status == "victory":
		tutorial.text = "Реактор стабилизирован. Прототипный забег завершен."
	elif state.run_status == "defeat":
		tutorial.text = "Реактор пробит. Враги слишком часто добирались до твоей дорожки."
	elif state.run_time < 8.0:
		tutorial.text = "Свайпай влево/вправо, чтобы вращать башню. Тапай нижнюю часть экрана слева или справа, чтобы менять дорожку."
	elif state.run_time < 18.0:
		tutorial.text = "Оружие стреляет автоматически. Держи опасных врагов на видимой стороне башни, чтобы сжечь их быстрее."
	else:
		tutorial.text = "Выживи до конца таймера. Когда энергия заполнится, выбери улучшение реактора."

	_refresh_upgrade_panel()
	restart_button.visible = state.run_status != "running"

func _refresh_upgrade_panel() -> void:
	if upgrade_panel == null:
		return

	var has_choices: bool = not state.pending_upgrade_choices.is_empty()
	upgrade_panel.visible = has_choices
	if not has_choices:
		for child in upgrade_panel.get_children():
			child.queue_free()
		return

	if upgrade_panel.get_child_count() == state.pending_upgrade_choices.size() + 1:
		return

	for child in upgrade_panel.get_children():
		child.queue_free()

	var title := Label.new()
	title.text = "Выбери улучшение реактора"
	title.add_theme_font_size_override("font_size", 28)
	upgrade_panel.add_child(title)

	for upgrade in state.pending_upgrade_choices:
		var button := Button.new()
		button.text = "%s - %s" % [upgrade["title"], upgrade["description"]]
		button.custom_minimum_size = Vector2(620.0, 58.0)
		button.pressed.connect(func(upgrade_id := String(upgrade["id"])) -> void:
			upgrade_selected.emit(upgrade_id)
		)
		upgrade_panel.add_child(button)
