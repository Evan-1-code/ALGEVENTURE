extends Node2D

## Main dungeon scene controller

@onready var hud = $HUD
@onready var battle_overlay = $BattleOverlay

var generator: DungeonGenerator
var player_controller: PlayerController
var battle_manager: BattleManager
var inventory: Inventory
var config: DungeonConfig
var player_state: PlayerState

var staircase_unlocked: bool = false

func _ready() -> void:
	# Get config and player state from DungeonManager
	if DungeonManager:
		config = DungeonManager.get_current_config()
		player_state = DungeonManager.get_player_state()
	else:
		config = DungeonConfig.new()
		player_state = PlayerState.new()
	
	# Initialize systems
	_initialize_dungeon()

func _initialize_dungeon() -> void:
	# Create generator
	generator = DungeonGenerator.new(config)
	generator.generate_floor()
	
	# Initialize inventory
	inventory = Inventory.new(player_state)
	
	# Create player controller
	player_controller = PlayerController.new()
	player_controller.config = config
	add_child(player_controller)
	player_controller.initialize(generator, player_state)
	
	# Create battle manager
	battle_manager = BattleManager.new()
	battle_manager.config = config
	add_child(battle_manager)
	
	# Connect signals
	_connect_signals()
	
	# Update HUD
	_update_hud()
	
	print("Dungeon initialized: ", config.dungeon_name, " - Floor ", player_state.current_floor)

func _connect_signals() -> void:
	player_controller.moved.connect(_on_player_moved)
	player_controller.move_depleted.connect(_on_move_depleted)
	player_controller.enemy_encountered.connect(_on_enemy_encountered)
	player_controller.chest_opened.connect(_on_chest_opened)
	player_controller.staircase_reached.connect(_on_staircase_reached)
	
	battle_manager.battle_ended.connect(_on_battle_ended)
	battle_manager.player_damaged.connect(_on_player_damaged)
	battle_manager.enemy_damaged.connect(_on_enemy_damaged)

func _on_player_moved(new_position: Vector2i) -> void:
	_update_hud()
	_check_staircase_unlock()

func _on_move_depleted() -> void:
	print("Out of moves! Game Over.")
	_game_over()

func _on_enemy_encountered(enemy: EnemyData) -> void:
	print("Enemy encountered: ", enemy.enemy_type)
	# Auto-start battle when encountering enemy
	_start_battle(enemy)

func _on_chest_opened(position: Vector2i) -> void:
	var loot = inventory.generate_chest_loot()
	inventory.apply_loot(loot)
	print("Chest opened! Got: ", loot)
	_update_hud()

func _on_staircase_reached() -> void:
	if staircase_unlocked:
		_advance_to_next_floor()
	else:
		print("Staircase is locked! Defeat more enemies.")

func _start_battle(enemy: EnemyData) -> void:
	battle_manager.start_battle(enemy, player_state)
	if battle_overlay:
		battle_overlay.show()
	print("Battle started with ", enemy.enemy_type)

func _on_battle_ended(victory: bool) -> void:
	if battle_overlay:
		battle_overlay.hide()
	
	if victory:
		print("Battle won!")
		player_state.kills_this_floor += 1
		player_controller.restore_moves()  # Restore moves after victory
		_check_staircase_unlock()
	else:
		print("Player defeated!")
		_game_over()
	
	_update_hud()

func _on_player_damaged(damage: float) -> void:
	print("Player took ", damage, " damage. Hearts: ", player_state.hearts)
	_update_hud()

func _on_enemy_damaged(damage: int) -> void:
	print("Enemy took ", damage, " damage.")

func _check_staircase_unlock() -> void:
	var required_kills = config.get_required_kills()
	if player_state.kills_this_floor >= required_kills and not staircase_unlocked:
		staircase_unlocked = true
		print("Staircase unlocked! You can proceed to the next floor.")

func _advance_to_next_floor() -> void:
	print("Advancing to next floor...")
	if DungeonManager:
		DungeonManager.advance_floor()
	get_tree().reload_current_scene()

func _game_over() -> void:
	print("Game Over! Respawning at checkpoint...")
	if DungeonManager:
		DungeonManager.respawn_at_checkpoint()

func _update_hud() -> void:
	if hud and hud.has_method("update_display"):
		hud.update_display(player_state, config)

func _input(event: InputEvent) -> void:
	if battle_manager.is_battle_active():
		return  # Don't process movement during battle
	
	if event.is_action_pressed("ui_accept"):
		# Save checkpoint
		if DungeonManager:
			DungeonManager.save_checkpoint()
			print("Checkpoint saved!")
	
	# Handle movement input
	var direction = Vector2i.ZERO
	if event.is_action_pressed("move_right"):
		direction.x = 1
	elif event.is_action_pressed("move_left"):
		direction.x = -1
	elif event.is_action_pressed("move_down"):
		direction.y = 1
	elif event.is_action_pressed("move_up"):
		direction.y = -1
	
	if direction != Vector2i.ZERO:
		var target = player_controller.current_position + direction
		player_controller.move_to(target)
