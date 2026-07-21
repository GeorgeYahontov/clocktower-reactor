extends RefCounted
class_name UpgradeCatalog

const UPGRADES := [
	{
		"id": "rapid_coils",
		"title": "Быстрые катушки",
		"description": "Автоогонь становится быстрее.",
		"stat": "fire_interval",
		"value": -0.04
	},
	{
		"id": "wide_lens",
		"title": "Широкая линза",
		"description": "Оружие лучше цепляет угрозы на соседних дорожках.",
		"stat": "lane_weight",
		"value": -0.18
	},
	{
		"id": "reactor_patch",
		"title": "Заплатка реактора",
		"description": "Восстановить 1 прочность реактора.",
		"stat": "integrity",
		"value": 1
	},
	{
		"id": "charged_cells",
		"title": "Заряженные ячейки",
		"description": "Убийства дают больше энергии для уровня.",
		"stat": "energy_bonus",
		"value": 1
	},
	{
		"id": "gyro_servos",
		"title": "Гиросерво",
		"description": "Башня вращается отзывчивее.",
		"stat": "rotation_speed",
		"value": 0.55
	},
	{
		"id": "hard_shell",
		"title": "Крепкий корпус",
		"description": "Увеличить максимум прочности реактора.",
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
