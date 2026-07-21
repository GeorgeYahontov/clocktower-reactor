extends CanvasLayer

var state
var label: Label
var tutorial: Label

func bind(game_state) -> void:
	state = game_state
	label = Label.new()
	label.position = Vector2(24.0, 24.0)
	label.add_theme_font_size_override("font_size", 28)
	add_child(label)

	tutorial = Label.new()
	tutorial.position = Vector2(24.0, 1090.0)
	tutorial.size = Vector2(672.0, 150.0)
	tutorial.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial.add_theme_font_size_override("font_size", 25)
	add_child(tutorial)
	refresh()

func refresh() -> void:
	if state == null or label == null:
		return
	var time_left: float = maxf(0.0, state.config.run_duration - state.run_time)
	label.text = "Clocktower Reactor\nTime left: %.0f\nLevel: %d\nEnergy: %d/%d\nIntegrity: %d\nKills: %d" % [
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
		tutorial.text = "Reactor stabilized. Prototype run complete."
	elif state.run_status == "defeat":
		tutorial.text = "Reactor breached. Enemies reached your lane too many times."
	elif state.run_time < 8.0:
		tutorial.text = "Drag sideways to rotate the tower. Tap the lower left/right side to change lanes."
	elif state.run_time < 18.0:
		tutorial.text = "Your weapon fires automatically. Keep threats on the visible face to burn them down."
	else:
		tutorial.text = "Survive until the timer reaches zero."
