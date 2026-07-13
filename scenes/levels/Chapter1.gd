extends Node2D

# Chapter1.gd
# Chapter 1: The Dark Awakening - Gameplay Level

@onready var player: CharacterBody2D = $Player
@onready var text_box: Control = $TextBox
@onready var battle_ui: Control = $BattleUI
@onready var pause_menu: Control = $PauseMenu
@onready var toriel: Node2D = $Toriel
@onready var dark_fountain: Node2D = $DarkFountain

var is_in_battle: bool = false
var is_paused: bool = false
var is_in_dialogue: bool = false
var dialogue_index: int = 0
var current_npc: Node2D = null
var has_seen_intro: bool = false
var dark_fountain_discovered: bool = false

# Level state
var doors_opened: Array = []
var puzzles_solved: Array = []
var enemies_defeated: Array = []

func _ready() -> void:
	# Connect signals
	BattleManager.battle_started.connect(_on_battle_started)
	BattleManager.battle_ended.connect(_on_battle_ended)
	
	# Initialize level
	AudioManager.play_music("res://audio/music/ruins_light.ogg", 1.0)
	
	# Show intro dialogue if first time
	if not GlobalVariables.get_flag("chapter1_intro_complete"):
		_show_level_intro()
	else:
		has_seen_intro = true

func _process(_delta: float) -> void:
	# Pause menu
	if Input.is_action_just_pressed("menu"):
		_toggle_pause()
	
	if is_paused or is_in_dialogue or is_in_battle:
		return
	
	# Check for interactions
	_check_interactions()
	
	# Check for save point
	_check_save_point()

func _toggle_pause() -> void:
	is_paused = !is_paused
	pause_menu.visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		AudioManager.pause_music()
	else:
		AudioManager.resume_music()

func _check_interactions() -> void:
	# Check player collision with NPCs/objects
	var overlapping = player.get_node("InteractionArea").get_overlapping_bodies()
	for body in overlapping:
		if body.is_in_group("interactable") and body.has_method("interact"):
			if Input.is_action_just_pressed("interact"):
				_start_interaction(body)

func _start_interaction(target: Node2D) -> void:
	is_in_dialogue = true
	current_npc = target
	target.interact(player)

func _end_interaction() -> void:
	is_in_dialogue = false
	current_npc = null
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

func _check_save_point() -> void:
	if player != null:
		var save_point = get_node_or_null("SavePoint")
		if save_point and player.global_position.distance_to(save_point.global_position) < 30:
			if Input.is_action_just_pressed("interact"):
				_save_game()

func _save_game() -> void:
	SaveSystem.save_game(0)
	_show_message("Game saved!")

func _show_message(text: String) -> void:
	var msg = Label.new()
	msg.text = text
	msg.global_position = Vector2(640, 300)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(msg)
	
	var tween = create_tween()
	tween.tween_property(msg, "modulate:a", 0.0, 2.0)
	tween.finished.connect(func(): msg.queue_free())

func _show_level_intro() -> void:
	is_in_dialogue = true
	
	var dialogue = {
		"lines": [
			{"text": "* You stand at the entrance to the Underground.", "speaker": ""},
			{"text": "* The air is thick with anticipation.", "speaker": ""},
			{"text": "* Something dark stirs in the distance...", "speaker": ""},
			{"text": "* Perhaps you should find someone to talk to.", "speaker": ""}
		]
	}
	
	DialogueManager.start_dialogue(dialogue)
	DialogueManager.dialogue_ended.connect(_on_intro_ended)

func _on_intro_ended() -> void:
	DialogueManager.dialogue_ended.disconnect(_on_intro_ended)
	GlobalVariables.set_flag("chapter1_intro_complete")
	has_seen_intro = true
	is_in_dialogue = false

# NPC Interactions
func interact_with_toriel() -> Dictionary:
	return {
		"speaker": "Toriel",
		"text": "Hello, my child. I am Toriel, caretaker of these ruins."
	}

# Battle system
func _on_battle_started(enemies: Array) -> void:
	is_in_battle = true
	battle_ui.show_battle_ui()
	player.hide()
	AudioManager.stop_music()
	AudioManager.play_music("res://audio/music/battle_theme.ogg", 0.8)

func _on_battle_ended(victory: bool) -> void:
	battle_ui.hide_battle_ui()
	player.show()
	is_in_battle = false
	
	if victory:
		AudioManager.play_music("res://audio/music/ruins_light.ogg", 1.0)
		_show_battle_victory_message()
	else:
		_show_game_over()

func _show_battle_victory_message() -> void:
	is_in_dialogue = true
	var dialogue = {
		"lines": [
			{"text": "* Victory!", "speaker": ""},
			{"text": "* You gained some EXP.", "speaker": ""},
			{"text": "* You gained some gold.", "speaker": ""}
		]
	}
	DialogueManager.start_dialogue(dialogue)
	DialogueManager.dialogue_ended.connect(_on_victory_dialogue_ended)

func _on_victory_dialogue_ended() -> void:
	DialogueManager.dialogue_ended.disconnect(_on_victory_dialogue_ended)
	is_in_dialogue = false

func _show_game_over() -> void:
	is_in_dialogue = true
	var dialogue = {
		"lines": [
			{"text": "* You collapsed...", "speaker": ""},
			{"text": "* But you determined to try again.", "speaker": ""}
		]
	}
	DialogueManager.start_dialogue(dialogue)
	DialogueManager.dialogue_ended.connect(_on_game_over_ended)

func _on_game_over_ended() -> void:
	DialogueManager.dialogue_ended.disconnect(_on_game_over_ended)
	# Respawn at last save point
	GlobalVariables.heal_full()
	is_in_dialogue = false

# Dark Fountain discovery
func discover_dark_fountain() -> void:
	if dark_fountain_discovered:
		return
	
	dark_fountain_discovered = true
	
	is_in_dialogue = true
	AudioManager.play_music("res://audio/music/dark_fountain.ogg", 1.0)
	
	var dialogue = {
		"lines": [
			{"text": "* You discovered a DARK FOUNTAIN!", "speaker": ""},
			{"text": "* Strange darkness pours from its depths...", "speaker": ""},
			{"text": "* The air feels heavy with dark energy.", "speaker": ""},
			{"text": "* Something this powerful should be investigated.", "speaker": ""},
			{"text": "* Perhaps Toriel would know more about this.", "speaker": ""}
		]
	}
	
	DialogueManager.start_dialogue(dialogue)
	DialogueManager.dialogue_ended.connect(_on_fountain_ended)

func _on_fountain_ended() -> void:
	DialogueManager.dialogue_ended.disconnect(_on_fountain_ended)
	GlobalVariables.set_flag("dark_fountain_discovered")
	is_in_dialogue = false

# Enter Dark World
func enter_dark_world() -> void:
	GameManager.transition_to_scene("res://scenes/levels/DarkRuins.tscn")

# Chapter completion
func complete_chapter() -> void:
	GlobalVariables.set_flag("chapter1_complete")
	
	var dialogue = {
		"lines": [
			{"text": "* You sealed the Dark Fountain!", "speaker": ""},
			{"text": "* The darkness receded... for now.", "speaker": ""},
			{"text": "* But more fountains remain...", "speaker": ""},
			{"text": "* CHAPTER 1 COMPLETE", "speaker": "", "is_title": true}
		]
	}
	
	DialogueManager.start_dialogue(dialogue)
	DialogueManager.dialogue_ended.connect(_on_chapter_complete)

func _on_chapter_complete() -> void:
	DialogueManager.dialogue_ended.disconnect(_on_chapter_complete)
	GameManager.transition_to_scene("res://scenes/core/MainMenu.tscn")
