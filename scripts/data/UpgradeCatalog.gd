extends RefCounted
class_name UpgradeCatalog

const UPGRADES := [
	{
		"id": "rapid_coils",
		"title": "Rapid Coils",
		"description": "Faster automatic fire.",
		"stat": "fire_interval",
		"value": -0.04
	},
	{
		"id": "wide_lens",
		"title": "Wide Lens",
		"description": "Shots can prefer threats across lanes.",
		"stat": "lane_weight",
		"value": -0.18
	},
	{
		"id": "reactor_patch",
		"title": "Reactor Patch",
		"description": "Restore one reactor integrity.",
		"stat": "integrity",
		"value": 1
	},
	{
		"id": "charged_cells",
		"title": "Charged Cells",
		"description": "Kills grant extra charge toward the next level.",
		"stat": "energy_bonus",
		"value": 1
	},
	{
		"id": "gyro_servos",
		"title": "Gyro Servos",
		"description": "Manual tower rotation becomes snappier.",
		"stat": "rotation_speed",
		"value": 0.55
	},
	{
		"id": "hard_shell",
		"title": "Hard Shell",
		"description": "Increase maximum reactor integrity.",
		"stat": "max_integrity",
		"value": 1
	}
]

static func pick_choices(count: int, seed_offset: int) -> Array[Dictionary]:
	var choices: Array[Dictionary] = []
	var start := seed_offset % UPGRADES.size()
	for i in count:
		choices.append(UPGRADES[(start + i * 2) % UPGRADES.size()].duplicate())
	return choices
