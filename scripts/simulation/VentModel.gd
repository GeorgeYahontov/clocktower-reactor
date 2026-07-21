extends RefCounted
class_name VentModel

var sector := 0
var lane := 0
var ttl := 8.0
var life := 8.0
var active := true

func setup(new_sector: int, new_lane: int, duration: float) -> void:
	sector = new_sector
	lane = new_lane
	ttl = duration
	life = duration
	active = true

func tick(delta: float) -> void:
	ttl -= delta
	if ttl <= 0.0:
		active = false

func urgency() -> float:
	if life <= 0.0:
		return 1.0
	return 1.0 - clampf(ttl / life, 0.0, 1.0)