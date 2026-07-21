extends CanvasLayer

signal upgrade_selected(upgrade_id: String)
signal restart_requested

var state
var status_panel: PanelContainer
var status_box: VBoxContainer
var status_header: Label
var energy_bar: ProgressBar
var integrity_bar: ProgressBar
var pulse_bar: ProgressBar
var tutorial: Label
var menu_button: Button
var help_panel: PanelContainer
var help_label: Label
var upgrade_title: Label
var upgrade_panel: HBoxContainer
var restart_button: Button

func bind(game_state) -> void:
	state = game_state
	status_panel = PanelContainer.new()
	status_panel.position = Vector2(18.0, 18.0)
	status_panel.size = Vector2(270.0, 126.0)
	status_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.08, 0.09, 0.72), Color(0.30, 0.56, 0.58, 0.42)))
	add_child(status_panel)

	status_box = VBoxContainer.new()
	status_box.size = Vector2(250.0, 108.0)
	status_box.add_theme_constant_override("separation", 7)
	status_panel.add_child(status_box)

	status_header = Label.new()
	status_header.add_theme_font_size_override("font_size", 18)
	status_box.add_child(status_header)

	energy_bar = _make_bar(Color(0.95, 0.78, 0.28, 0.95))
	status_box.add_child(energy_bar)

	integrity_bar = _make_bar(Color(0.44, 0.95, 0.82, 0.95))
	status_box.add_child(integrity_bar)

	pulse_bar = _make_bar(Color(0.52, 0.70, 1.0, 0.95))
	status_box.add_child(pulse_bar)

	menu_button = Button.new()
	menu_button.text = "?"
	menu_button.position = Vector2(650.0, 22.0)
	menu_button.size = Vector2(48.0, 48.0)
	menu_button.add_theme_font_size_override("font_size", 22)
	menu_button.pressed.connect(func() -> void:
		help_panel.visible = not help_panel.visible
	)
	add_child(menu_button)

	help_panel = PanelContainer.new()
	help_panel.position = Vector2(326.0, 78.0)
	help_panel.size = Vector2(372.0, 414.0)
	help_panel.visible = false
	help_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.08, 0.09, 0.92), Color(0.42, 0.78, 0.76, 0.60)))
	add_child(help_panel)

	help_label = Label.new()
	help_label.size = Vector2(348.0, 390.0)
	help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_label.add_theme_font_size_override("font_size", 17)
	help_label.text = "Управление\nA/D: шаг по башне\nW/S: дорожка вверх/вниз\nQ/E или мышь: вращать\nSpace/ПКМ: импульс\n\nЛегенда\nФиолетовый !: аварийный вентиль\nСиний щит: тяжелый враг\nОранжевый блок: обычный враг\nРадар: вид сверху\nКрасная вспышка: урон\nЗеленая вспышка: ремонт\nЗолото: апгрейд\n\nHUD\nЖелтая полоса: энергия\nЗеленая: реактор\nСиняя: импульс"
	help_panel.add_child(help_label)

	tutorial = Label.new()
	tutorial.position = Vector2(24.0, 1018.0)
	tutorial.size = Vector2(672.0, 94.0)
	tutorial.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial.add_theme_font_size_override("font_size", 21)
	add_child(tutorial)

	upgrade_title = Label.new()
	upgrade_title.position = Vector2(24.0, 1120.0)
	upgrade_title.size = Vector2(672.0, 24.0)
	upgrade_title.add_theme_font_size_override("font_size", 18)
	upgrade_title.text = "Быстрый апгрейд - выбери на ходу"
	upgrade_title.visible = false
	add_child(upgrade_title)

	upgrade_panel = HBoxContainer.new()
	upgrade_panel.position = Vector2(24.0, 1148.0)
	upgrade_panel.size = Vector2(672.0, 104.0)
	upgrade_panel.add_theme_constant_override("separation", 12)
	upgrade_panel.visible = false
	add_child(upgrade_panel)

	restart_button = Button.new()
	restart_button.text = "Начать заново"
	restart_button.position = Vector2(250.0, 1128.0)
	restart_button.size = Vector2(220.0, 64.0)
	restart_button.visible = false
	restart_button.pressed.connect(func() -> void:
		restart_requested.emit()
	)
	add_child(restart_button)
	refresh()

func refresh() -> void:
	if state == null or status_header == null:
		return
	var time_left: float = maxf(0.0, state.config.run_duration - state.run_time)
	status_header.text = "%.0f c   Ур.%d" % [time_left, state.level]
	energy_bar.max_value = state.config.energy_per_level
	energy_bar.value = state.energy
	integrity_bar.max_value = maxf(1.0, float(state.max_reactor_integrity))
	integrity_bar.value = state.reactor_integrity
	pulse_bar.max_value = state.config.pulse_cooldown
	pulse_bar.value = state.config.pulse_cooldown - state.pulse_cooldown_remaining
	pulse_bar.modulate.a = 1.0 if state.pulse_cooldown_remaining <= 0.0 else 0.58

	if tutorial == null:
		return
	if state.run_status == "victory":
		tutorial.text = "Реактор стабилизирован. Прототипный забег завершен."
	elif state.run_status == "defeat":
		tutorial.text = "Реактор пробит. Враги или аварии слишком сильно повредили систему."
	elif state.run_time < 8.0:
		tutorial.text = "Беги по окружности башни: A/D. W/S меняют дорожку. Вращай Q/E или мышью, чтобы вывести угрозы на передний сектор."
	elif state.run_time < 18.0:
		tutorial.text = "Фиолетовый ! - аварийный вентиль. Встань на его сектор и дорожку, чтобы закрыть до истечения таймера."
	elif state.run_time < 28.0:
		tutorial.text = "Синие щиты - тяжелые враги. Space или ПКМ дает импульс рядом с тобой и помогает в критический момент."
	else:
		tutorial.text = "Выживи до конца таймера: закрывай вентили, держи врагов под автоогнем и выбирай апгрейды снизу без остановки забега."

	_refresh_upgrade_panel()
	restart_button.visible = state.run_status != "running"

func _refresh_upgrade_panel() -> void:
	if upgrade_panel == null:
		return

	var has_choices: bool = not state.pending_upgrade_choices.is_empty() and state.run_status == "running"
	upgrade_panel.visible = has_choices
	upgrade_title.visible = has_choices
	if not has_choices:
		for child in upgrade_panel.get_children():
			child.queue_free()
		return

	if upgrade_panel.get_child_count() == state.pending_upgrade_choices.size():
		return

	for child in upgrade_panel.get_children():
		child.queue_free()

	for upgrade in state.pending_upgrade_choices:
		var button := Button.new()
		button.text = "%s  %s\n%s" % [upgrade["icon"], upgrade["title"], upgrade["description"]]
		button.custom_minimum_size = Vector2(330.0, 92.0)
		button.add_theme_font_size_override("font_size", 15)
		button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.07, 0.13, 0.15, 0.92), Color(0.36, 0.72, 0.72, 0.72)))
		button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.10, 0.18, 0.19, 0.96), Color(0.95, 0.82, 0.36, 0.90)))
		button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.13, 0.23, 0.22, 1.0), Color(0.52, 1.0, 0.78, 0.95)))
		button.pressed.connect(func(upgrade_id := String(upgrade["id"])) -> void:
			upgrade_selected.emit(upgrade_id)
		)
		upgrade_panel.add_child(button)

func _make_bar(fill: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(242.0, 18.0)
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _make_panel_style(Color(0.02, 0.04, 0.05, 0.78), Color(0.18, 0.28, 0.29, 0.70)))
	bar.add_theme_stylebox_override("fill", _make_panel_style(fill, fill))
	return bar

func _make_panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style