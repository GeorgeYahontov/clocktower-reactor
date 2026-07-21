extends Node

var state: RefCounted
var _players: Array[AudioStreamPlayer] = []
var _repair_seen := 0
var _damage_seen := 0
var _upgrade_seen := 0
var _pulse_seen := 0
var _shot_seen := 0

func bind(game_state: RefCounted) -> void:
	state = game_state
	for i in 6:
		var player := AudioStreamPlayer.new()
		player.volume_db = -12.0
		add_child(player)
		_players.append(player)

func update() -> void:
	if state == null:
		return
	var repair_count := 0
	var damage_count := 0
	var upgrade_count := 0
	for flash in state.event_flashes:
		match String(flash["kind"]):
			"repair":
				repair_count += 1
			"damage":
				damage_count += 1
			"upgrade":
				upgrade_count += 1
	if repair_count > _repair_seen:
		_play_tone(640.0, 0.10, -10.0)
		_play_tone(920.0, 0.08, -14.0)
	if damage_count > _damage_seen:
		_play_tone(115.0, 0.16, -8.0)
	if upgrade_count > _upgrade_seen:
		_play_tone(520.0, 0.10, -12.0)
		_play_tone(780.0, 0.12, -11.0)
	_repair_seen = repair_count
	_damage_seen = damage_count
	_upgrade_seen = upgrade_count

	if state.pulse_effects.size() > _pulse_seen:
		_play_tone(180.0, 0.12, -10.0)
		_play_tone(360.0, 0.18, -16.0)
	_pulse_seen = state.pulse_effects.size()

	if state.shot_traces.size() > _shot_seen:
		_play_tone(980.0, 0.035, -24.0)
	_shot_seen = state.shot_traces.size()

func _play_tone(frequency: float, duration: float, volume_db: float) -> void:
	var player := _next_player()
	player.stop()
	player.volume_db = volume_db
	player.stream = _make_tone(frequency, duration)
	player.play()

func _next_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	return _players[0]

func _make_tone(frequency: float, duration: float) -> AudioStreamWAV:
	var mix_rate := 22050
	var sample_count := int(float(mix_rate) * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in sample_count:
		var t := float(i) / float(mix_rate)
		var fade := 1.0 - float(i) / maxf(1.0, float(sample_count - 1))
		var sample := int(sin(TAU * frequency * t) * fade * 18000.0)
		data.encode_s16(i * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream