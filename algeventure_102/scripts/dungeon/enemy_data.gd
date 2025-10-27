extends Resource
class_name EnemyData

## Enemy data structure

@export var enemy_id: int = 0
@export var enemy_type: String = "slime"
@export var hp: int = 1
@export var difficulty_tier: int = 1
@export var xp_reward: int = 10
@export var taunts: Array[String] = ["Prepare to fail!", "Math is hard!"]
@export var position: Vector2i = Vector2i.ZERO

var is_defeated: bool = false

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		is_defeated = true

func to_dict() -> Dictionary:
	return {
		"enemy_id": enemy_id,
		"enemy_type": enemy_type,
		"hp": hp,
		"difficulty_tier": difficulty_tier,
		"xp_reward": xp_reward,
		"position": {"x": position.x, "y": position.y},
		"is_defeated": is_defeated
	}

func from_dict(data: Dictionary) -> void:
	enemy_id = data.get("enemy_id", 0)
	enemy_type = data.get("enemy_type", "slime")
	hp = data.get("hp", 1)
	difficulty_tier = data.get("difficulty_tier", 1)
	xp_reward = data.get("xp_reward", 10)
	var pos_data = data.get("position", {"x": 0, "y": 0})
	position = Vector2i(pos_data.get("x", 0), pos_data.get("y", 0))
	is_defeated = data.get("is_defeated", false)
