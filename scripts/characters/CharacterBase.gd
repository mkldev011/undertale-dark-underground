extends CharacterBody2D
class_name CharacterBase

# CharacterBase.gd
# Base class for all playable characters

signal health_changed(current: int, maximum: int)
signal state_changed(new_state: String)
signal animation_finished(anim_name: String)
signal direction_changed(dir: Vector2)

@export var character_name: String = "Character"
@export var stats: Dictionary = {
	"hp": 20,
	"max_hp": 20,
	"attack": 10,
	"defense": 10,
	"level": 1
}

# Movement
@export var move_speed: float = 200.0
@export var facing_direction: Vector2 = Vector2.DOWN
@export var is_moving: bool = false

# Animation
@export var animated_sprite: AnimatedSprite2D
@export var sprite_facing: bool = true  # Flip sprite based on direction

# Interaction
var can_interact: bool = true
var interaction_range: float = 50.0
var current_interactable: Node2D = null

# Character states
enum CharacterState {
	IDLE,
	WALKING,
	RUNNING,
	INTERACTING,
	HURT,
	DEAD
}

var current_state: CharacterState = CharacterState.IDLE

func _ready() -> void:
	add_to_group("character")
	_setup_sprite()
	load_character_stats()

func _setup_sprite() -> void:
	if animated_sprite == null:
		animated_sprite = get_node_or_null("AnimatedSprite2D")
		if animated_sprite == null:
			# Create a simple placeholder sprite if none exists
			animated_sprite = AnimatedSprite2D.new()
			animated_sprite.name = "AnimatedSprite2D"
			add_child(animated_sprite)

func _physics_process(_delta: float) -> void:
	match current_state:
		CharacterState.IDLE:
			velocity = Vector2.ZERO
		CharacterState.WALKING:
			pass
		CharacterState.RUNNING:
			pass
	
	move_and_slide()

# Load stats from GlobalVariables
func load_character_stats() -> void:
	if GlobalVariables.character_stats.has(character_name):
		stats = GlobalVariables.character_stats[character_name].duplicate()

# Save current stats to GlobalVariables
func save_character_stats() -> void:
	GlobalVariables.character_stats[character_name] = stats.duplicate()
	health_changed.emit(stats["hp"], stats["max_hp"])

# Movement functions
func move_in_direction(direction: Vector2) -> void:
	facing_direction = direction.normalized()
	velocity = facing_direction * move_speed
	
	if facing_direction != Vector2.ZERO:
		update_facing_direction()
		is_moving = true
		_change_state(CharacterState.WALKING)
	else:
		is_moving = false
		_change_state(CharacterState.IDLE)

func stop_moving() -> void:
	velocity = Vector2.ZERO
	is_moving = false
	_change_state(CharacterState.IDLE)

# Direction helpers
func update_facing_direction() -> void:
	direction_changed.emit(facing_direction)
	
	if sprite_facing and animated_sprite:
		# Flip sprite based on horizontal direction
		if facing_direction.x < 0:
			animated_sprite.flip_h = true
		elif facing_direction.x > 0:
			animated_sprite.flip_h = false

# Animation control
func play_animation(anim_name: String, force: bool = false) -> void:
	if animated_sprite:
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim_name):
			animated_sprite.play(anim_name, force)
		else:
			# Fallback for missing animations
			animated_sprite.play()

func _on_animation_finished() -> void:
	if animated_sprite:
		animation_finished.emit(animated_sprite.animation)

# State management
func _change_state(new_state: CharacterState) -> void:
	if current_state == new_state:
		return
	
	var old_state = current_state
	current_state = new_state
	state_changed.emit(CharacterState.keys()[new_state])
	
	# Handle state transitions
	match new_state:
		CharacterState.IDLE:
			play_animation("idle")
		CharacterState.WALKING:
			play_animation("walk")
		CharacterState.HURT:
			play_animation("hurt")
		CharacterState.DEAD:
			play_animation("dead")

# Health management
func take_damage(amount: int) -> void:
	var actual_damage = max(1, amount - stats.get("defense", 0))
	stats["hp"] = max(0, stats["hp"] - actual_damage)
	health_changed.emit(stats["hp"], stats["max_hp"])
	
	_change_state(CharacterState.HURT)
	
	if stats["hp"] <= 0:
		_change_state(CharacterState.DEAD)

func heal(amount: int) -> void:
	stats["hp"] = min(stats["max_hp"], stats["hp"] + amount)
	health_changed.emit(stats["hp"], stats["max_hp"])

func is_alive() -> bool:
	return stats["hp"] > 0

# Interaction system
func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable") and can_interact:
		current_interactable = body

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body == current_interactable:
		current_interactable = null

func interact() -> void:
	if current_interactable and can_interact:
		current_interactable.interact(self)
		_change_state(CharacterState.INTERACTING)

# Get interaction direction for dialogue positioning
func get_interaction_direction() -> String:
	if abs(facing_direction.x) > abs(facing_direction.y):
		return "left" if facing_direction.x < 0 else "right"
	else:
		return "up" if facing_direction.y < 0 else "down"
