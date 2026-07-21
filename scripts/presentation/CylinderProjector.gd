extends RefCounted
class_name CylinderProjector

var center := Vector2(360.0, 650.0)
var radius_x := 245.0
var lane_y := 96.0
var base_y := 160.0
var depth_scale := 0.34

func project(sector: int, lane: int, rotation: float, sector_count: int) -> Dictionary:
	var angle := ((float(sector) - rotation) / float(sector_count)) * TAU
	var side := sin(angle)
	var depth := cos(angle)
	var x := center.x + side * radius_x
	var y := center.y + base_y - float(lane) * lane_y - depth * 36.0
	var scale := lerpf(0.62, 1.18, (depth + 1.0) * 0.5)
	var alpha := lerpf(0.18, 1.0, (depth + 1.0) * 0.5)
	return {
		"position": Vector2(x, y),
		"scale": scale,
		"alpha": alpha,
		"depth": depth,
		"front": depth > -0.15
	}
