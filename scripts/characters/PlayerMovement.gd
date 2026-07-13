extends CharacterBody2D

# PlayerMovement.gd
# Player character controller for CompleteLevel

signal interacted(target: Node2D)

@export var move_speed: float = 200.0
@export var interact_distance: float = 50.0

@onready var sprite: Sprite2D = $PlayerSprite
@onready var interaction_area: Area2D = $InteractionArea

var facing_direction: Vector2 = Vector2.DOWN
var can_move: bool = true
var current_interactable: Node2D = null

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	
	# Load sprite
	_load_sprite()

func _load_sprite() -> void:
	var sprite_path = "res://assets/sprites/characters/frisk_idle.png"
	if ResourceLoader.exists(sprite_path):
		sprite.texture = load(sprite_path)

func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Get input
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")
	
	# Apply movement
	velocity = input_dir * move_speed
	
	# Update facing
	if input_dir != Vector2.ZERO:
		facing_direction = input_dir.normalized()
		_update_sprite_direction()
	
	# Animation
	if input_dir != Vector2.ZERO:
		sprite.play("walk")
	else:
		sprite.play("idle")
	
	move_and_slide()

func _update_sprite_direction() -> void:
	if abs(facing_direction.x) > 0.1:
		sprite.flip_h = facing_direction.x < 0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		current_interactable = body

func _on_body_exited(body: Node2D) -> void:
	if body == current_interactable:
		current_interactable = null

func interact() -> void:
	if current_interactable:
		interacted.emit(current_interactable)

func set_can_move(value: bool) -> void:
	can_move = value
	if not can_move:
		velocity = Vector2.ZERO
