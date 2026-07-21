extends CanvasLayer

var state
var label: Label

func bind(game_state) -> void:
	state = game_state
	label = Label.new()
	label.position = Vector2(24.0, 24.0)
	label.add_theme_font_size_override("font_size", 28)
	add_child(label)
	refresh()

func refresh() -> void:
	if state == null or label == null:
		return
	label.text = "Clocktower Reactor\nTime: %.1f\nLevel: %d\nEnergy: %d" % [
		state.run_time,
		state.level,
		state.energy
	]
