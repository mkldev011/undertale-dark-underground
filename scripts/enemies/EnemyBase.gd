extends Node2D
class_name EnemyBase

# EnemyBase.gd
# Base class for all enemies in battle

signal enemy_hit(damage: int)
signal enemy_damaged(damage: int)
signal enemy_defeated
signal spare_attempted(success: bool)
signal hp_changed(current: int, maximum: int)
signal state_changed(new_state: String)

@export var enemy_name: String = "Enemy"
@export var enemy_id: String = "generic_enemy"
@export var description: String = "A mysterious creature."

# Stats
@export var stats: Dictionary = {
	"hp": 40,
	"max_hp": 40,
	"attack": 10,
	"defense": 5,
	"exp_given": 10,
	"gold_given": 8,
	"can_spare": true,
	"can_escape": true
}

# Combat
var current_hp: int
var is_defeated: bool = false
var spare_requirements: Array = []  # Flags needed to spare this enemy

# Enemy states
enum EnemyState {
	IDLE,
	ATTACKING,
	HURT,
	SPARED,
	DEFEATED
}

var current_state: EnemyState = EnemyState.IDLE

# Visual
@export var sprite: Sprite2D
@export var animated_sprite: AnimatedSprite2D
@export var damage_popup_scene: PackedScene

# Spare tracking
var spare_attempts: int = 0
var is_spared: bool = false
var mercy_percentage: int = 0  # For enemy HP bar display

func _ready() -> void:
	current_hp = stats["hp"]
	hp_changed.emit(current_hp, stats["max_hp"])

# Take damage from player attack
func take_damage(amount: int, is_critical: bool = false) -> void:
	var actual_damage = max(1, amount - stats.get("defense", 0))
	current_hp = max(0, current_hp - actual_damage)
	
	enemy_damaged.emit(actual_damage)
	hp_changed.emit(current_hp, stats["max_hp"])
	
	_show_damage_popup(actual_damage, is_critical)
	_play_hurt_animation()
	
	if current_hp <= 0:
		_trigger_defeat()

func _show_damage_popup(amount: int, is_critical: bool) -> void:
	# Create damage popup
	var popup = Label.new()
	popup.text = str(amount)
	popup.global_position = global_position + Vector2(0, -30)
	popup.z_index = 100
	
	if is_critical:
		popup.add_theme_font_size_override("font_size", 32)
		popup.modulate = Color.YELLOW
	else:
		popup.add_theme_font_size_override("font_size", 24)
		popup.modulate = Color.WHITE
	
	get_tree().root.add_child(popup)
	
	# Animate and remove
	var tween = create_tween()
	tween.tween_property(popup, "position:y", popup.position.y - 50, 0.5)
	tween.tween_property(popup, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func(): popup.queue_free())

func _play_hurt_animation() -> void:
	_change_state(EnemyState.HURT)
	
	# Flash white
	if sprite:
		var original_modulate = sprite.modulate
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = original_modulate

# Reduce HP directly (for non-attack damage)
func reduce_hp(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, stats["max_hp"])
	
	if current_hp <= 0:
		_trigger_defeat()

# Check if can be spared
func can_be_spared() -> bool:
	if not stats.get("can_spare", true):
		return false
	
	# Check all spare requirements
	for req_flag in spare_requirements:
		if not GlobalVariables.has_flag(req_flag):
			return false
	
	return true

# Attempt to spare the enemy
func attempt_spare() -> bool:
	spare_attempts += 1
	spare_attempted.emit(can_be_spared())
	
	if can_be_spared():
		is_spared = true
		_trigger_spare()
		return true
	else:
		# Update mercy percentage based on attempts
		mercy_percentage = min(100, spare_attempts * 20)
		return false

# Execute spare action
func _trigger_spare() -> void:
	_change_state(EnemyState.SPARED)
	_play_spare_animation()

# Trigger defeat
func _trigger_defeat() -> void:
	if is_defeated:
		return
	
	is_defeated = true
	_change_state(EnemyState.DEFEATED)
	enemy_defeated.emit()
	_play_defeat_animation()

# Animation helpers
func _play_spare_animation() -> void:
	if animated_sprite:
		animated_sprite.play("spared")
	elif sprite:
		# Fade out effect
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		tween.finished.connect(func(): queue_free())

func _play_defeat_animation() -> void:
	if animated_sprite:
		animated_sprite.play("defeated")
		await animated_sprite.animation_finished
	queue_free()
	# In a real implementation, this would show EXP gained

func _play_hurt_animation() -> void:
	if animated_sprite:
		animated_sprite.play("hurt")

# State management
func _change_state(new_state: EnemyState) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	state_changed.emit(EnemyState.keys()[new_state])

# Get enemy data for battle system
func get_enemy_data() -> Dictionary:
	return {
		"id": enemy_id,
		"name": enemy_name,
		"hp": current_hp,
		"max_hp": stats["max_hp"],
		"attack": stats["attack"],
		"defense": stats["defense"],
		"exp_given": stats["exp_given"],
		"gold_given": stats["gold_given"],
		"can_spare": stats["can_spare"],
		"can_escape": stats.get("can_escape", true),
		"spare_requirements": spare_requirements.duplicate()
	}

# ACT responses - override in specific enemies
func get_act_response(action_id: String) -> Dictionary:
	var responses = {
		"talk": {"text": "* You talked to " + enemy_name + ".", "success": true},
		"check": {"text": "* " + enemy_name + " - " + str(stats["hp"]) + " HP\n" + description, "success": true}
	}
	
	return responses.get(action_id, {"text": "* Nothing happened.", "success": false})
