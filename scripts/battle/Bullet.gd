extends Area2D
class_name Bullet

# Bullet.gd
# Bullet-hell projectile for enemy attacks

@export var speed: float = 3.0
@export var bullet_damage: int = 5
@export var wave_amplitude: float = 0.0
@export var wave_frequency: float = 0.0

var direction: Vector2 = Vector2.DOWN
var lifetime: float = 10.0
var elapsed: float = 0.0
var is_active: bool = true

func _ready() -> void:
	add_to_group("bullet")
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if not is_active:
		return
	
	elapsed += delta
	
	# Wave movement
	var offset = Vector2.ZERO
	if wave_amplitude > 0:
		offset.y = sin(elapsed * wave_frequency) * wave_amplitude
	
	# Move bullet
	position += direction * speed * 60 * delta
	position += offset
	
	# Remove if out of bounds or lifetime expired
	if elapsed > lifetime or _is_out_of_bounds():
		queue_free()

func _is_out_of_bounds() -> bool:
	var screen_size = get_viewport_rect().size
	return position.x < -50 or position.x > screen_size.x + 50 or position.y < -50 or position.y > screen_size.y + 50

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_soul"):
		# Emit damage signal instead of calling method directly
		BattleManager._player_hit()
		queue_free()

func setup(dir: Vector2, spd: float = 3.0, dmg: int = 5) -> void:
	direction = dir.normalized()
	speed = spd
	bullet_damage = dmg
