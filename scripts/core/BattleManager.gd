extends Node

# BattleManager.gd
# Core battle system - handles turn-based combat with bullet-hell mechanics

signal battle_started(enemies: Array)
signal battle_ended(victory: bool)
signal turn_started(actor: String)
signal turn_ended(actor: String)
signal damage_dealt(target: String, amount: int)
signal player_damaged(amount: int)
signal enemy_damaged(enemy_name: String, amount: int)
signal tp_changed(new_tp: int)
signal spare_attempted(enemy_name: String)
signal enemy_spared(enemy_name: String)
signal enemy_defeated(enemy_name: String)
signal level_up(character: String, new_level: int)
signal mercy_updated

enum BattleState {
	INTRO,
	PLAYER_TURN,
	ENEMY_TURN,
	ATTACKING,
	MAGIC,
	ITEMS,
	ACT,
	SPARE,
	DEFEND,
	CHOOSING_TARGET,
	ENEMY_ATTACK,
	BULLET_HELL,
	VICTORY,
	DEFEAT,
	ESCAPING
}

enum ActionType {
	ATTACK,
	ACT,
	ITEM,
	SPARE,
	DEFEND,
	MAGIC
}

var current_state: BattleState = BattleState.INTRO
var battle_scene: Node
var current_turn: String = "player"

# Battle participants
var party_members: Array = []  # Active party in battle
var enemies: Array = []  # Active enemies
var current_enemy_index: int = 0

# TP System (for magic)
var current_tp: int = 0
var max_tp: int = 100

# Player stats
var player_stats: Dictionary = {
	"hp": 20,
	"max_hp": 20,
	"attack": 10,
	"defense": 10,
	"level": 1,
	"weapon": "",
	"armor": ""
}

# Spare/mercy tracking
var spare_attempts: Dictionary = {}  # Tracks spare attempts per enemy
var mercy_points: Dictionary = {}  # Mercy percentage per enemy

# Combat flags
var is_defending: bool = false
var is_acting: bool = false
var can_spare: bool = false
var enemies_remaining: int = 0

# Bullet hell tracking
var bullets: Array = []
var player_soul_position: Vector2 = Vector2(640, 450)
var player_soul: Node

func _ready() -> void:
	pass

# ============ BATTLE INITIALIZATION ============

func start_battle(enemy_data: Array, party: Array = ["Frisk"]) -> void:
	party_members = party.duplicate()
	enemies = enemy_data.duplicate()
	enemies_remaining = enemies.size()
	
	# Reset battle state
	current_tp = 50  # Start with some TP
	current_state = BattleState.INTRO
	
	# Reset spare tracking
	spare_attempts.clear()
	mercy_points.clear()
	for enemy in enemies:
		var enemy_id = enemy.get("id", str(enemies.find(enemy)))
		spare_attempts[enemy_id] = 0
		mercy_points[enemy_id] = 0
	
	# Get player stats from GlobalVariables
	_update_player_stats()
	
	battle_started.emit(enemies)

func _update_player_stats() -> void:
	# Merge stats from GlobalVariables
	if GlobalVariables.character_stats.has("frisk"):
		var frisk_stats = GlobalVariables.character_stats["frisk"]
		player_stats["hp"] = frisk_stats.get("hp", 20)
		player_stats["max_hp"] = frisk_stats.get("max_hp", 20)
		player_stats["attack"] = frisk_stats.get("attack", 10)
		player_stats["defense"] = frisk_stats.get("defense", 10)
		player_stats["level"] = frisk_stats.get("level", 1)

# ============ TURN MANAGEMENT ============

func start_player_turn() -> void:
	current_state = BattleState.PLAYER_TURN
	is_defending = false
	is_acting = false
	current_enemy_index = 0
	turn_started.emit("player")

func end_player_turn() -> void:
	turn_ended.emit("player")
	_start_enemy_turn()

func _start_enemy_turn() -> void:
	current_state = BattleState.ENEMY_ATTACK
	current_turn = "enemy"
	turn_started.emit("enemy")
	
	# Start enemy attack sequence
	_execute_enemy_attack()

# ============ COMBAT ACTIONS ============

# Basic attack
func attack(enemy_index: int) -> void:
	if current_state != BattleState.PLAYER_TURN:
		return
	
	current_state = BattleState.ATTACKING
	
	var damage = _calculate_damage(player_stats["attack"], enemies[enemy_index]["defense"])
	enemies[enemy_index]["hp"] -= damage
	
	enemy_damaged.emit(enemies[enemy_index].get("name", "Enemy"), damage)
	damage_dealt.emit(enemies[enemy_index].get("name", "Enemy"), damage)
	
	AudioManager.play_battle_damage_enemy()
	
	# Check if enemy defeated
	if enemies[enemy_index]["hp"] <= 0:
		_defeat_enemy(enemy_index)
	else:
		# Small delay then continue
		await get_tree().create_timer(0.5).timeout
		_check_battle_end()

# Calculate damage
func _calculate_damage(attack_power: int, enemy_defense: int) -> int:
	var base_damage = attack_power - (enemy_defense / 2)
	var variance = randi() % 4 - 2  # -2 to +2 damage variance
	return max(1, base_damage + variance)

# Defend action
func defend() -> void:
	if current_state != BattleState.PLAYER_TURN:
		return
	
	is_defending = true
	current_state = BattleState.DEFEND
	
	# Reduce incoming damage by 50% this turn
	await get_tree().create_timer(0.3).timeout
	end_player_turn()

# Spare action
func spare(enemy_index: int) -> void:
	if current_state != BattleState.PLAYER_TURN:
		return
	
	current_state = BattleState.SPARE
	var enemy_id = enemies[enemy_index].get("id", str(enemy_index))
	spare_attempts[enemy_id] += 1
	
	spare_attempted.emit(enemies[enemy_index].get("name", "Enemy"))
	
	# Check spare conditions
	if _can_spare_enemy(enemies[enemy_index], spare_attempts[enemy_id]):
		_spare_enemy(enemy_index)
	else:
		# Show spare failed message
		await get_tree().create_timer(0.5).timeout
		end_player_turn()

# Check if enemy can be spared
func _can_spare_enemy(enemy_data: Dictionary, attempts: int) -> bool:
	# Check if enemy has "can_spare" flag
	if not enemy_data.get("can_spare", true):
		return false
	
	# Check if ACT requirements were met
	if enemy_data.has("spare_requirements"):
		var requirements = enemy_data["spare_requirements"]
		# Check if all requirements met
		for req in requirements:
			if not GlobalVariables.game_flags.get(req, false):
				return false
	
	# Add mercy chance based on attempts and requirements
	var mercy_chance = attempts * 20  # 20% per attempt
	return randi() % 100 < mercy_chance

# Spare the enemy
func _spare_enemy(enemy_index: int) -> void:
	enemy_spared.emit(enemies[enemy_index].get("name", "Enemy"))
	enemies.remove_at(enemy_index)
	enemies_remaining -= 1
	
	_check_battle_end()

# ACT action - for special interactions
func act(action_id: String, enemy_index: int) -> void:
	if current_state != BattleState.PLAYER_TURN:
		return
	
	current_state = BattleState.ACT
	is_acting = true
	
	# Get ACT response
	var response = _execute_act(action_id, enemies[enemy_index])
	
	# Display ACT result
	_show_act_result(response)
	
	# Update spare conditions based on ACT
	_update_spare_conditions(action_id, enemy_index)
	
	await get_tree().create_timer(0.5).timeout
	end_player_turn()

# Execute ACT command
func _execute_act(action_id: String, enemy_data: Dictionary) -> Dictionary:
	# Base ACT responses - override in specific battles
	var act_responses = {
		"talk": {"success": true, "text": "* You talked to the enemy."},
		"comfort": {"success": true, "text": "* You tried to comfort them."},
		"threaten": {"success": false, "text": "* They don't seem impressed."}
	}
	
	return act_responses.get(action_id, {"success": false, "text": "* Nothing happened."})

# Show ACT result in dialogue
func _show_act_result(response: Dictionary) -> void:
	# This will integrate with DialogueManager
	pass

# Update spare conditions based on ACTs performed
func _update_spare_conditions(action_id: String, enemy_index: int) -> void:
	# Set game flags for completed ACTs
	var flag_name = "act_%s_%s" % [enemies[enemy_index].get("id", str(enemy_index)), action_id]
	GlobalVariables.set_flag(flag_name, true)

# ============ MAGIC SYSTEM ============

# Use magic spell
func use_magic(spell_id: String, target_index: int = -1) -> bool:
	if current_state != BattleState.PLAYER_TURN:
		return false
	
	# Get spell data
	var spell_data = _get_spell_data(spell_id)
	if spell_data == null:
		return false
	
	# Check TP cost
	var tp_cost = spell_data.get("tp_cost", 0)
	if current_tp < tp_cost:
		# Not enough TP
		return false
	
	current_tp -= tp_cost
	tp_changed.emit(current_tp)
	
	current_state = BattleState.MAGIC
	AudioManager.play_battle_magic()
	
	# Execute spell effects
	_execute_magic_spell(spell_data, target_index)
	
	return true

# Get spell data from database
func _get_spell_data(spell_id: String) -> Dictionary:
	var spells = {
		"heal": {"name": "Heal", "tp_cost": 10, "type": "heal", "power": 20},
		"fire": {"name": "Fire", "tp_cost": 8, "type": "damage", "power": 15},
		"ice": {"name": "Ice", "tp_cost": 8, "type": "damage", "power": 12, "effect": "freeze"},
		"lightning": {"name": "Lightning", "tp_cost": 12, "type": "damage", "power": 20}
	}
	return spells.get(spell_id, null)

# Execute magic spell
func _execute_magic_spell(spell_data: Dictionary, target_index: int) -> void:
	match spell_data["type"]:
		"heal":
			var heal_amount = spell_data["power"]
			player_stats["hp"] = min(player_stats["hp"] + heal_amount, player_stats["max_hp"])
		"damage":
			if target_index >= 0 and target_index < enemies.size():
				var damage = _calculate_damage(spell_data["power"], enemies[target_index]["defense"])
				enemies[target_index]["hp"] -= damage
				enemy_damaged.emit(enemies[target_index].get("name", "Enemy"), damage)
	
	await get_tree().create_timer(0.5).timeout
	_check_battle_end()

# Add TP (called after enemy attacks)
func add_tp(amount: int) -> void:
	current_tp = min(current_tp + amount, max_tp)
	tp_changed.emit(current_tp)

# ============ ITEMS ============

# Use item in battle
func use_item(item_id: String, target_index: int = -1) -> bool:
	if current_state != BattleState.PLAYER_TURN:
		return false
	
	# Check if item exists in inventory
	if item_id not in GlobalVariables.inventory:
		return false
	
	# Remove from inventory
	GlobalVariables.remove_item(item_id)
	
	current_state = BattleState.ITEMS
	AudioManager.play_battle_item()
	
	# Execute item effect
	_execute_item_effect(item_id, target_index)
	
	return true

# Execute item effect
func _execute_item_effect(item_id: String, target_index: int) -> void:
	var items = {
		"bandage": {"type": "heal", "power": 10},
		"cookie": {"type": "heal", "power": 10},
		"full_heal": {"type": "full_heal", "power": 0},
		"str_up": {"type": "buff", "stat": "attack", "power": 2},
		"def_up": {"type": "buff", "stat": "defense", "power": 2}
	}
	
	var item_data = items.get(item_id)
	if item_data == null:
		return
	
	match item_data["type"]:
		"heal":
			player_stats["hp"] = min(player_stats["hp"] + item_data["power"], player_stats["max_hp"])
		"full_heal":
			player_stats["hp"] = player_stats["max_hp"]

# ============ ENEMY ATTACKS ============

# Execute enemy attack
func _execute_enemy_attack() -> void:
	if enemies.is_empty():
		_check_battle_end()
		return
	
	# Get current enemy's attack
	var enemy = enemies[0]  # First enemy attacks
	var attack_data = enemy.get("attack_pattern", {"name": "Attack", "damage": 5, "bullets": 5})
	
	# Start bullet hell sequence
	current_state = BattleState.BULLET_HELL
	_start_bullet_hell(attack_data)

# Bullet hell system
var bullet_scene: PackedScene = preload("res://scenes/battle/Bullet.tscn")

func _start_bullet_hell(attack_data: Dictionary) -> void:
	var bullet_count = attack_data.get("bullets", 5)
	var bullet_pattern = attack_data.get("pattern", "spread")
	
	# Create bullets based on pattern
	match bullet_pattern:
		"spread":
			_create_spread_bullets(bullet_count)
		"aimed":
			_create_aimed_bullets(bullet_count)
		"wave":
			_create_wave_bullets(bullet_count)
		"random":
			_create_random_bullets(bullet_count)
	
	# Player needs to dodge - enable soul movement
	_enable_player_soul()

# Bullet creation patterns
func _create_spread_bullets(count: int) -> void:
	for i in range(count):
		var bullet = bullet_scene.instantiate()
		bullet.position = Vector2(640, 100)  # Top of battle box
		var angle = deg_to_rad(-60 + (120.0 / (count - 1)) * i)
		bullet.direction = Vector2(cos(angle), sin(angle)) * 3
		add_child(bullet)
		bullets.append(bullet)

func _create_aimed_bullets(count: int) -> void:
	for i in range(count):
		var bullet = bullet_scene.instantiate()
		bullet.position = Vector2(640, 100)
		await get_tree().create_timer(0.3 * i).timeout
		# Aim at player position
		var dir = (player_soul_position - bullet.position).normalized()
		bullet.direction = dir * 4
		add_child(bullet)
		bullets.append(bullet)

func _create_wave_bullets(count: int) -> void:
	for i in range(count):
		var bullet = bullet_scene.instantiate()
		bullet.position = Vector2(200 + (800.0 / count) * i, 100)
		bullet.direction = Vector2(0, 2)
		bullet.wave_pattern = true
		add_child(bullet)
		bullets.append(bullet)

func _create_random_bullets(count: int) -> void:
	for i in range(count):
		var bullet = bullet_scene.instantiate()
		bullet.position = Vector2(randf_range(100, 1180), 50)
		bullet.direction = Vector2(randf_range(-0.5, 0.5), randf_range(0.5, 1.5)).normalized() * 3
		add_child(bullet)
		bullets.append(bullet)
		await get_tree().create_timer(0.2).timeout

# Enable player soul for dodging
func _enable_player_soul() -> void:
	# This will be handled by the battle UI scene
	pass

# Player got hit by bullet
func _player_hit() -> void:
	var damage = enemies[0].get("attack_pattern", {}).get("damage", 5)
	
	if is_defending:
		damage = damage / 2
	
	player_stats["hp"] -= damage
	player_damaged.emit(damage)
	AudioManager.play_battle_damage_player()
	
	if player_stats["hp"] <= 0:
		_trigger_defeat()

# Player dodged successfully
func _player_dodged() -> void:
	add_tp(3)  # Reward TP for dodging
	mercy_updated.emit()

# ============ BATTLE END CONDITIONS ============

func _defeat_enemy(enemy_index: int) -> void:
	var enemy_name = enemies[enemy_index].get("name", "Enemy")
	enemy_defeated.emit(enemy_name)
	
	enemies.remove_at(enemy_index)
	enemies_remaining -= 1
	
	_check_battle_end()

func _check_battle_end() -> void:
	if enemies.is_empty():
		_trigger_victory()
	elif player_stats["hp"] <= 0:
		_trigger_defeat()
	else:
		end_player_turn()

func _trigger_victory() -> void:
	current_state = BattleState.VICTORY
	AudioManager.play_battle_victory()
	
	# Calculate rewards
	var exp_gained = _calculate_exp_reward()
	var gold_gained = _calculate_gold_reward()
	
	# Apply rewards
	_add_exp(exp_gained)
	GlobalVariables.add_gold(gold_gained)
	
	battle_ended.emit(true)

func _trigger_defeat() -> void:
	current_state = BattleState.DEFEAT
	battle_ended.emit(false)

func _calculate_exp_reward() -> int:
	var total_exp = 0
	# Add enemy EXP values
	return total_exp

func _calculate_gold_reward() -> int:
	var total_gold = 0
	# Add enemy gold values
	return total_gold

func _add_exp(amount: int) -> void:
	# Level up calculation
	var exp_needed = player_stats["level"] * 20 + 10
	# Add EXP and check level up
	pass

# ============ ESCAPE ============

func attempt_escape() -> bool:
	if current_state != BattleState.PLAYER_TURN:
		return false
	
	current_state = BattleState.ESCAPING
	
	# Escape success chance based on enemy
	var escape_chance = 70  # Base 70%
	
	if randi() % 100 < escape_chance:
		battle_ended.emit(true)  # true = escaped
		return true
	else:
		# Failed to escape
		await get_tree().create_timer(0.3).timeout
		end_player_turn()
		return false

# ============ END BATTLE ============

func end_battle() -> void:
	# Clean up bullets
	for bullet in bullets:
		if is_instance_valid(bullet):
			bullet.queue_free()
	bullets.clear()
	
	# Reset state
	current_state = BattleState.INTRO
	enemies.clear()
	party_members.clear()
