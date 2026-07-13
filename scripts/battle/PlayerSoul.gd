extends Area2D
class_name PlayerSoul

# PlayerSoul.gd
# Player's soul during battle - can be moved with keyboard

signal soul_hit(damage: int)

@export var move_speed: float = 300.0

var current_hp: int = 20
var max_hp: int = 20
var is_defending: bool = false
var can_move: bool = true

func _ready() -> void:
	add_to_group("player_soul")

func _process(_delta: float) -> void:
	if not can_move:
		return
	
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")
	
	position += input_dir * move_speed * _delta
	
	# Keep in bounds (battle box)
	var box_left = 180.0
	var box_right = 500.0
	var box_top = 150.0
	var box_bottom = 450.0
	
	position.x = clamp(position.x, box_left, box_right)
	position.y = clamp(position.y, box_top, box_bottom)

func take_damage(amount: int) -> void:
	var final_damage = amount
	if is_defending:
		final_damage = int(amount * 0.5)
	
	current_hp -= final_damage
	soul_hit.emit(final_damage)
	
	if current_hp <= 0:
		current_hp = 0
		BattleManager._on_player_defeated()

func defend() -> void:
	is_defending = true

func stop_defend() -> void:
	is_defending = false

func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)

func full_heal() -> void:
	current_hp = max_hp
	is_defending = false

func get_hp() -> int:
	return current_hp

func get_max_hp() -> int:
	return max_hp

func set_max_hp(hp: int) -> void:
	max_hp = hp
	current_hp = hp
