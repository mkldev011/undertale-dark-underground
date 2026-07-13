extends CharacterBody2D
class_name PlayerController

# PlayerController.gd
# Player character movement and interaction

@export var move_speed: float = 200.0
@export var interact_distance: float = 40.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

signal interacted_with(target: Node2D)

var is_in_interaction: bool = false
var facing_direction: Vector2 = Vector2.DOWN
var current_interactable: Node2D = null

# Animation states
var is_walking: bool = false
var is_anim_locked: bool = false

func _ready() -> void:
	add_to_group("player")
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if is_in_interaction:
		velocity = Vector2.ZERO
		return
	
	# Get input direction
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")
	
	# Apply movement
	velocity = input_dir * move_speed
	
	# Update facing direction
	if input_dir != Vector2.ZERO:
		facing_direction = input_dir.normalized()
		_update_sprite_direction()
		
		if not is_walking:
			is_walking = true
			_play_animation("walk")
	else:
		if is_walking:
			is_walking = false
			_play_animation("idle")
	
	move_and_slide()

func _update_sprite_direction() -> void:
	# Flip sprite based on horizontal direction
	if abs(facing_direction.x) > 0.1:
		sprite.flip_h = facing_direction.x < 0

func _play_animation(anim_name: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)

func _process(_delta: float) -> void:
	if is_in_interaction:
		return
	
	# Handle interaction
	if Input.is_action_just_pressed("interact"):
		_try_interact()

func _try_interact() -> void:
	if current_interactable and current_interactable.has_method("interact"):
		is_in_interaction = true
		interacted_with.emit(current_interactable)
		current_interactable.interact(self)

func end_interaction() -> void:
	is_in_interaction = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		current_interactable = body

func _on_body_exited(body: Node2D) -> void:
	if body == current_interactable:
		current_interactable = null

# Called by SaveSystem to restore position
func restore_position(pos: Vector2) -> void:
	global_position = pos

func get_save_data() -> Dictionary:
	return {
		"position": global_position,
		"facing": facing_direction
	}
