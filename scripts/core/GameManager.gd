extends Node

# GameManager.gd
# Central game state manager - handles game-wide state and transitions

signal game_state_changed(new_state: GameState)
signal game_paused
signal game_unpaused
signal scene_changed(scene_name: String)

enum GameState {
	MENU,
	PLAYING,
	BATTLE,
	DIALOGUE,
	PAUSED,
	TITLE_SCREEN,
	GAME_OVER,
	TRANSITION
}

var current_state: GameState = GameState.MENU
var previous_state: GameState = GameState.MENU
var current_scene_path: String = ""
var transition_scene_path: String = ""
var is_transitioning: bool = false

# Game settings
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var text_speed: float = 1.0
var battle_difficulty: int = 0  # 0 = Normal

# Screen shake for effects
var screen_shake: bool = false
var shake_intensity: float = 0.0
var shake_duration: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()

func _process(delta: float) -> void:
	if screen_shake:
		shake_duration -= delta
		if shake_duration <= 0:
			screen_shake = false
			shake_intensity = 0.0

# State management
func set_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	
	previous_state = current_state
	current_state = new_state
	game_state_changed.emit(new_state)
	
	match new_state:
		GameState.PAUSED:
			get_tree().paused = true
			game_paused.emit()
		GameState.PLAYING, GameState.MENU, GameState.DIALOGUE:
			if previous_state == GameState.PAUSED:
				get_tree().paused = false
				game_unpaused.emit()

func restore_previous_state() -> void:
	set_state(previous_state)

# Scene transitions with fade effect
func transition_to_scene(scene_path: String, fade_color: Color = Color.BLACK) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	transition_scene_path = scene_path
	
	# Create transition overlay
	var transition = ColorRect.new()
	transition.color = fade_color
	transition.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition.z_index = 1000
	add_child(transition)
	
	# Animate fade to black
	var tween = create_tween()
	tween.tween_property(transition, "color:a", 1.0, 0.5)
	await tween.finished
	
	# Change scene
	await get_tree().change_scene_to_file(scene_path)
	current_scene_path = scene_path
	scene_changed.emit(scene_path.get_file().get_basename())
	
	# Fade back in
	tween = create_tween()
	tween.tween_property(transition, "color:a", 0.0, 0.5)
	await tween.finished
	
	transition.queue_free()
	is_transitioning = false

# Quick scene change without transition
func change_scene(scene_path: String) -> void:
	await get_tree().change_scene_to_file(scene_path)
	current_scene_path = scene_path
	scene_changed.emit(scene_path.get_file().get_basename())

# Screen shake effect
func shake(intensity: float = 5.0, duration: float = 0.3) -> void:
	screen_shake = true
	shake_intensity = intensity
	shake_duration = duration

# Settings persistence
func save_settings() -> void:
	var settings = {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"text_speed": text_speed,
		"battle_difficulty": battle_difficulty
	}
	SaveSystem.save_data("user://settings.sav", settings)

func load_settings() -> void:
	var settings = SaveSystem.load_data("user://settings.sav")
	if settings:
		master_volume = settings.get("master_volume", 1.0)
		music_volume = settings.get("music_volume", 0.8)
		sfx_volume = settings.get("sfx_volume", 1.0)
		text_speed = settings.get("text_speed", 1.0)
		battle_difficulty = settings.get("battle_difficulty", 0)

# Quit game
func quit_game() -> void:
	save_settings()
	get_tree().quit()

# Restart game (new game)
func restart_game() -> void:
	SaveSystem.delete_save("user://savegame.sav")
	get_tree().reload_current_scene()
