extends RefCounted
class_name EnemyModel

var sector := 0
var lane := 0
var hp := 2
var speed := 0.8
var _step_progress := 0.0

func advance(delta: float, player_sector: int, player_lane: int, sector_count: int) -> void:
	_step_progress += delta * speed
	if _step_progress < 1.0:
		return

	_step_progress = 0.0
	if lane < player_lane:
		lane += 1
	elif lane > player_lane:
		lane -= 1
	else:
		var clockwise := wrapi(player_sector - sector, 0, sector_count)
		var counter := wrapi(sector - player_sector, 0, sector_count)
		if clockwise <= counter:
			sector = wrapi(sector + 1, 0, sector_count)
		else:
			sector = wrapi(sector - 1, 0, sector_count)
