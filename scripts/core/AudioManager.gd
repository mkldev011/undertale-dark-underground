extends Node

# AudioManager.gd
# Handles all audio playback - music, sound effects, ambient sounds

const MUSIC_BUS = 0
const SFX_BUS = 1
const AMBIENT_BUS = 2

var current_music: AudioStreamPlayer
var current_music_path: String = ""
var music_fade_tween: Tween

# Sound effect pool for overlapping sounds
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE = 8

# Ambient sounds
var ambient_player: AudioStreamPlayer
var current_ambient_path: String = ""

func _ready() -> void:
	_setup_audio_players()
	_apply_volume_settings()

func _setup_audio_players() -> void:
	# Create music player
	current_music = AudioStreamPlayer.new()
	current_music.bus = "Music"
	add_child(current_music)
	
	# Create ambient player
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Ambient"
	add_child(ambient_player)
	
	# Create SFX pool
	for i in range(SFX_POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		player.volume_db = -10  # Start quieter for mixing
		add_child(player)
		sfx_players.append(player)

func _apply_volume_settings() -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS, linear_to_db(GameManager.music_volume * GameManager.master_volume))
	AudioServer.set_bus_volume_db(SFX_BUS, linear_to_db(GameManager.sfx_volume * GameManager.master_volume))
	AudioServer.set_bus_volume_db(AMBIENT_BUS, linear_to_db(GameManager.sfx_volume * GameManager.master_volume))

# ============ MUSIC FUNCTIONS ============

# Play music with optional fade in
func play_music(path: String, fade_duration: float = 0.0, volume: float = 1.0, loop: bool = true) -> void:
	if path == current_music_path and current_music.playing:
		return
	
	# Stop current music with fade
	if current_music.playing:
		if fade_duration > 0:
			_fade_out_music(fade_duration)
		else:
			current_music.stop()
	
	# Load and play new music
	var music = load(path)
	if music == null:
		push_error("Failed to load music: " + path)
		return
	
	current_music.stream = music
	current_music.stream.loop = loop
	current_music.volume_db = linear_to_db(volume * GameManager.music_volume * GameManager.master_volume)
	
	if fade_duration > 0:
		current_music.volume_db = linear_to_db(0.0)
		current_music.play()
		_fade_in_music(fade_duration)
	else:
		current_music.play()
	
	current_music_path = path

func _fade_in_music(duration: float) -> void:
	if music_fade_tween:
		music_fade_tween.kill()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_property(current_music, "volume_db", 
		linear_to_db(GameManager.music_volume * GameManager.master_volume), duration)

func _fade_out_music(duration: float) -> void:
	if music_fade_tween:
		music_fade_tween.kill()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_property(current_music, "volume_db", -80.0, duration)
	await music_fade_tween.finished
	current_music.stop()
	current_music.volume_db = linear_to_db(GameManager.music_volume * GameManager.master_volume)

# Stop music
func stop_music(fade_duration: float = 0.0) -> void:
	if fade_duration > 0:
		_fade_out_music(fade_duration)
	else:
		current_music.stop()
	current_music_path = ""

# Pause/resume music
func pause_music() -> void:
	current_music.stream_paused = true

func resume_music() -> void:
	current_music.stream_paused = false

# Get current music state
func is_music_playing() -> bool:
	return current_music.playing

# ============ SOUND EFFECT FUNCTIONS ============

# Play a sound effect (uses pool)
func play_sfx(path: String, volume: float = 1.0, pitch_scale: float = 1.0) -> void:
	# Find available player
	var player = _get_available_sfx_player()
	if player == null:
		return
	
	var sfx = load(path)
	if sfx == null:
		return
	
	player.stream = sfx
	player.volume_db = linear_to_db(volume * GameManager.sfx_volume * GameManager.master_volume)
	player.pitch_scale = pitch_scale
	player.play()

# Play UI sounds (menu navigation, confirm, cancel)
func play_ui_select() -> void:
	play_sfx("res://audio/sound_effects/ui/ui_select.ogg", 0.7)
func play_ui_confirm() -> void:
	play_sfx("res://audio/sound_effects/ui/ui_confirm.ogg", 0.8)
func play_ui_cancel() -> void:
	play_sfx("res://audio/sound_effects/ui/ui_cancel.ogg", 0.6)
func play_ui_move() -> void:
	play_sfx("res://audio/sound_effects/ui/ui_move.ogg", 0.5)

# Play battle sounds
func play_battle_hit() -> void:
	play_sfx("res://audio/sound_effects/battle/battle_hit.ogg", 0.9)
func play_battle_damage_enemy() -> void:
	play_sfx("res://audio/sound_effects/battle/battle_damage_enemy.ogg", 0.8)
func play_battle_damage_player() -> void:
	play_sfx("res://audio/sound_effects/battle/battle_damage_player.ogg", 0.7)
func play_battle_victory() -> void:
	play_sfx("res://audio/sound_effects/battle/battle_victory.ogg", 0.8)
func play_battle_magic() -> void:
	play_sfx("res://audio/sound_effects/battle/battle_magic.ogg", 0.7)
func play_battle_item() -> void:
	play_sfx("res://audio/sound_effects/battle/battle_item.ogg", 0.6)

# Get available SFX player from pool
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	# If all are busy, use the first one (will cut off)
	return sfx_players[0]

# ============ AMBIENT SOUNDS ============

func play_ambient(path: String, volume: float = 0.5, fade_duration: float = 0.0) -> void:
	if current_ambient_path == path and ambient_player.playing:
		return
	
	if fade_duration > 0 and ambient_player.playing:
		var tween = create_tween()
		tween.tween_property(ambient_player, "volume_db", -80.0, fade_duration)
		await tween.finished
		ambient_player.stop()
	
	var ambient = load(path)
	if ambient:
		ambient_player.stream = ambient
		ambient_player.volume_db = linear_to_db(volume * GameManager.sfx_volume * GameManager.master_volume)
		ambient_player.play()
		current_ambient_path = path

func stop_ambient(fade_duration: float = 0.0) -> void:
	if fade_duration > 0:
		var tween = create_tween()
		tween.tween_property(ambient_player, "volume_db", -80.0, fade_duration)
		await tween.finished
	ambient_player.stop()
	current_ambient_path = ""

# ============ VOLUME CONTROL ============

func update_volumes() -> void:
	_apply_volume_settings()

# Adjust volume in real-time
func set_music_volume(volume: float) -> void:
	GameManager.music_volume = volume
	_apply_volume_settings()

func set_sfx_volume(volume: float) -> void:
	GameManager.sfx_volume = volume
	_apply_volume_settings()

func set_master_volume(volume: float) -> void:
	GameManager.master_volume = volume
	_apply_volume_settings()
