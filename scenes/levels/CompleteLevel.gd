extends Node2D

# CompleteLevel.gd
# Full playable Chapter 1 with multiple areas, enemies, and secret boss

signal area_changed(area_name: String)
signal enemy_encountered(enemy_data: Dictionary)
signal boss_encountered(boss_name: String)
signal chapter_completed

# Areas in this level
enum Area {
	RUINS_ENTRANCE,
	TORIEL_HOME,
	PUZZLE_ROOM,
	DARK_FOUNTAIN_ROOM,
	BOSS_ARENA
}

# Current state
var current_area: Area = Area.RUINS_ENTRANCE
var areas_visited: Array = []
var enemies_defeated: int = 0
var secret_boss_unlocked: bool = false
var secret_boss_defeated: bool = false
var chapter_complete: bool = false

# Player
@onready var player: CharacterBody2D = $Player
@onready var player_sprite: Sprite2D = $Player/PlayerSprite

# UI
@onready var text_box: Control = $TextBox
@onready var battle_ui: Control = $BattleUI
@onready var hud: Control = $HUD
@onready var pause_menu: Control = $PauseMenu

# NPCs and objects
@onready var toriel: Node2D = $Toriel
@onready var flowey: Node2D = $Flowey
@onready var dark_fountain: Node2D = $DarkFountain
@onready var save_point: Node2D = $SavePoint

# Area nodes
@onready var ruins_entrance: Node2D = $Areas/RuinsEntrance
@onready var toriel_home: Node2D = $Areas/TorielHome
@onready var puzzle_room: Node2D = $Areas/PuzzleRoom
@onready var dark_room: Node2D = $Areas/DarkFountainRoom
@onready var boss_arena: Node2D = $Areas/BossArena

# Encounter zones
var encounter_zones: Array = []

# Game state
var is_in_dialogue: bool = false
var is_in_battle: bool = false
var is_paused: bool = false
var can_move: bool = true

func _ready() -> void:
	_setup_game()
	_setup_areas()
	_setup_encounter_zones()
	_connect_signals()
	
	# Start game
	_start_intro()

func _setup_game() -> void:
	# Set player stats if new game
	if GlobalVariables.character_stats["Frisk"]["hp"] == 20:
		GlobalVariables.character_stats["Frisk"]["max_hp"] = 20
		GlobalVariables.character_stats["Frisk"]["hp"] = 20
		GlobalVariables.character_stats["Frisk"]["attack"] = 10
		GlobalVariables.character_stats["Frisk"]["defense"] = 10
	
	# Give starting items
	if GlobalVariables.inventory.is_empty():
		GlobalVariables.add_item("bandage")
		GlobalVariables.add_item("bandage")
		GlobalVariables.add_item("cookie")
	
	# Set initial TP
	BattleManager.max_tp = 100
	BattleManager.current_tp = 50

func _setup_areas() -> void:
	# Hide all areas initially
	for area in $Areas.get_children():
		area.visible = false
	
	_show_area(Area.RUINS_ENTRANCE)

func _setup_encounter_zones() -> void:
	# Define encounter zones with enemy groups
	encounter_zones = [
		{
			"area": Area.RUINS_ENTRANCE,
			"enemies": ["froggit"],
			"chance": 0.15,
			"zone_rect": Rect2(200, 100, 400, 200)
		},
		{
			"area": Area.PUZZLE_ROOM,
			"enemies": ["froggit", "whimsun"],
			"chance": 0.20,
			"zone_rect": Rect2(0, 0, 640, 720)
		},
		{
			"area": Area.DARK_FOUNTAIN_ROOM,
			"enemies": ["shadow"],
			"chance": 0.40,
			"zone_rect": Rect2(0, 0, 640, 720)
		}
	]

func _connect_signals() -> void:
	BattleManager.battle_started.connect(_on_battle_started)
	BattleManager.battle_ended.connect(_on_battle_ended)
	
	# Player interaction
	player.connect("interacted", _on_player_interact)

func _start_intro() -> void:
	is_in_dialogue = true
	can_move = false
	
	# Intro sequence
	var intro_lines = [
		{"speaker": "", "text": "* You stand at the entrance to the Underground."},
		{"speaker": "", "text": "* The air grows cold as you descend..."},
		{"speaker": "", "text": "* Fallen leaves crunch beneath your feet."},
		{"speaker": "", "text": "* Something dark stirs in the shadows ahead."},
		{"speaker": "???", "text": "Howdy! I'm FLOWEY! FLOWEY THE FLOWER!"},
		{"speaker": "Flowey", "text": "Hmm, you're new to the Underground, aren't you?"},
		{"speaker": "Flowey", "text": "Don't worry! I'll teach you how things work here..."},
		{"speaker": "Flowey", "text": "You see, in this world... it's KILL or BE killed."},
		{"speaker": "Flowey", "text": "But wait... something's different this time..."},
		{"speaker": "Flowey", "text": "There's a strange darkness about you..."},
		{"speaker": "Flowey", "text": "Interesting. VERY interesting..."},
		{"speaker": "Flowey", "text": "Well, good luck, human! You'll need it!"},
	]
	
	_start_dialogue_sequence(intro_lines, "_on_intro_complete")

func _on_intro_complete() -> void:
	is_in_dialogue = false
	can_move = true
	GlobalVariables.set_flag("intro_complete")
	
	# Set up flowey interaction
	flowey.add_to_group("interactable")

func _process(_delta: float) -> void:
	if is_paused or is_in_dialogue or is_in_battle:
		return
	
	# Handle pause
	if Input.is_action_just_pressed("menu"):
		_toggle_pause()
		return
	
	if not can_move:
		return
	
	# Check interactions
	_check_interactions()
	
	# Check encounters
	_check_random_encounter()

func _check_interactions() -> void:
	if Input.is_action_just_pressed("interact"):
		var bodies = player.get_node("InteractionArea").get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("interactable"):
				_interact_with(body)
				return

func _interact_with(target: Node2D) -> void:
	if target.name == "Toriel":
		_interact_toriel()
	elif target.name == "Flowey":
		_interact_flowey()
	elif target.name == "DarkFountain":
		_interact_dark_fountain()
	elif target.name == "SavePoint":
		_save_game()
	elif target.name.begins_with("Door"):
		_change_area(target)

func _interact_toriel() -> void:
	is_in_dialogue = true
	can_move = false
	
	if not GlobalVariables.get_flag("toriel_met"):
		_toriel_first_meeting()
	elif not GlobalVariables.get_flag("dark_fountain_discovered"):
		_toriel_about_fountain()
	elif not GlobalVariables.get_flag("chapter_complete"):
		_toriel_encouragement()
	else:
		_toriel_final()

func _toriel_first_meeting() -> void:
	GlobalVariables.set_flag("toriel_met")
	
	var lines = [
		{"speaker": "Toriel", "text": "Ah! A human child! Are you alright?"},
		{"speaker": "Toriel", "text": "I am TORIEL, caretaker of these Ruins."},
		{"speaker": "Toriel", "text": "The Underground can be dangerous for little ones like you."},
		{"speaker": "Toriel", "text": "But don't worry! I'll protect you."},
		{"speaker": "Toriel", "text": "Have you noticed anything... strange lately?"},
		{"speaker": "Toriel", "text": "The shadows seem darker than usual..."},
		{"speaker": "Toriel", "text": "Something is happening in the Underground."},
		{"speaker": "Toriel", "text": "Perhaps we should investigate together."},
	]
	
	_start_dialogue_sequence(lines, "_on_toriel_first_meeting_done")

func _on_toriel_first_meeting_done() -> void:
	is_in_dialogue = false
	can_move = true

func _toriel_about_fountain() -> void:
	var lines = [
		{"speaker": "Toriel", "text": "My child, have you seen the darkness spreading?"},
		{"speaker": "Toriel", "text": "I sense a Dark Fountain nearby..."},
		{"speaker": "Toriel", "text": "These fountains are dangerous, child."},
		{"speaker": "Toriel", "text": "If you find one, please tell me immediately."},
		{"speaker": "Toriel", "text": "The balance between Light and Dark is at stake."},
	]
	_start_dialogue_sequence(lines, "_end_dialogue")

func _toriel_encouragement() -> void:
	var lines = [
		{"speaker": "Toriel", "text": "Stay determined, my child."},
		{"speaker": "Toriel", "text": "I believe in you."},
		{"speaker": "Toriel", "text": "Remember: You are stronger than you think."},
	]
	_start_dialogue_sequence(lines, "_end_dialogue")

func _toriel_final() -> void:
	var lines = [
		{"speaker": "Toriel", "text": "You did it, my child!"},
		{"speaker": "Toriel", "text": "The darkness receded because of your bravery."},
		{"speaker": "Toriel", "text": "I am so proud of you."},
	]
	_start_dialogue_sequence(lines, "_end_dialogue")

func _interact_flowey() -> void:
	is_in_dialogue = true
	can_move = false
	
	var lines = [
		{"speaker": "Flowey", "text": "Oh, it's you again!"},
		{"speaker": "Flowey", "text": "Still alive? That's... unexpected."},
		{"speaker": "Flowey", "text": "That darkness you carry... it's fascinating."},
		{"speaker": "Flowey", "text": "Makes me wonder what you're capable of."},
		{"speaker": "Flowey", "text": "Well well well... See you around!"},
	]
	_start_dialogue_sequence(lines, "_end_dialogue")

func _interact_dark_fountain() -> void:
	if not GlobalVariables.get_flag("dark_fountain_activated"):
		_activate_dark_fountain()
	else:
		_approach_sealed_fountain()

func _activate_dark_fountain() -> void:
	is_in_dialogue = true
	can_move = false
	
	AudioManager.play_music("res://audio/music/dark_fountain.ogg", 0.8)
	
	var lines = [
		{"speaker": "", "text": "* You approach the Dark Fountain..."},
		{"speaker": "", "text": "* The darkness pulses and writhes before you."},
		{"speaker": "", "text": "* Strange whispers echo in your mind..."},
		{"speaker": "???", "text": "Another one who seeks the darkness..."},
		{"speaker": "???", "text": "Foolish mortal..."},
		{"speaker": "???", "text": "The Shadow Guardian will consume all!"},
		{"speaker": "", "text": "* A SHADOW GUARDIAN emerges from the fountain!"},
		{"speaker": "", "text": "* This is the SECRET BOSS!"},
		{"speaker": "", "text": "* You must defeat it to seal the fountain!"},
	]
	
	_start_dialogue_sequence(lines, "_start_secret_boss")

func _start_secret_boss() -> void:
	secret_boss_unlocked = true
	_change_area_by_name("BossArena")
	_start_boss_battle()

func _start_boss_battle() -> void:
	is_in_battle = true
	can_move = false
	
	# Secret boss data
	var boss_data = [
		{
			"id": "shadow_guardian",
			"name": "SHADOW GUARDIAN",
			"hp": 200,
			"max_hp": 200,
			"attack": 15,
			"defense": 8,
			"attack_pattern": {
				"name": "Shadow Strike",
				"damage": 10,
				"bullets": 8,
				"pattern": "spread"
			},
			"can_spare": false,
			"description": "Guardian of the Dark Fountain. Born from pure shadow."
		}
	]
	
	BattleManager.start_battle(boss_data, ["Frisk"])
	battle_ui.show_battle_ui()

func _approach_sealed_fountain() -> void:
	var lines = [
		{"speaker": "", "text": "* The Dark Fountain has been sealed."},
		{"speaker": "", "text": "* The darkness has receded."},
	]
	_start_dialogue_sequence(lines, "_end_dialogue")

func _check_random_encounter() -> void:
	var zone = _get_current_encounter_zone()
	if zone == null:
		return
	
	if randf() < zone["chance"]:
		_trigger_random_battle(zone["enemies"])

func _get_current_encounter_zone() -> Dictionary:
	for zone in encounter_zones:
		if zone["area"] == current_area:
			var player_pos = player.global_position
			var rect = zone["zone_rect"]
			if rect.has_point(player_pos):
				return zone
	return null

func _trigger_random_battle(enemies: Array) -> void:
	is_in_battle = true
	can_move = false
	
	var enemy_id = enemies[randi() % enemies.size()]
	var enemy_data = _get_enemy_data(enemy_id)
	
	BattleManager.start_battle([enemy_data], ["Frisk"])
	battle_ui.show_battle_ui()

func _get_enemy_data(enemy_id: String) -> Dictionary:
	var enemies = {
		"froggit": {
			"id": "froggit",
			"name": "Froggit",
			"hp": 20,
			"max_hp": 20,
			"attack": 6,
			"defense": 2,
			"attack_pattern": {"name": "Ribbit", "damage": 4, "bullets": 3, "pattern": "spread"},
			"can_spare": true,
			"spare_requirements": ["froggit_talked"],
			"description": "A frog-like monster. It watches you intently."
		},
		"whimsun": {
			"id": "whimsun",
			"name": "Whimsun",
			"hp": 15,
			"max_hp": 15,
			"attack": 5,
			"defense": 1,
			"attack_pattern": {"name": "Blush", "damage": 3, "bullets": 2, "pattern": "aimed"},
			"can_spare": true,
			"spare_requirements": ["whimsun_encouraged"],
			"description": "A nervous moth monster."
		},
		"shadow": {
			"id": "shadow",
			"name": "Shadow Creature",
			"hp": 40,
			"max_hp": 40,
			"attack": 10,
			"defense": 5,
			"attack_pattern": {"name": "Dark Strike", "damage": 8, "bullets": 5, "pattern": "wave"},
			"can_spare": true,
			"spare_requirements": ["shadow_light"],
			"description": "A creature born from the Dark Fountain."
		}
	}
	return enemies.get(enemy_id, enemies["froggit"])

func _on_battle_started(enemies: Array) -> void:
	is_in_battle = true
	can_move = false
	battle_ui.show_battle_ui()
	AudioManager.stop_music()
	AudioManager.play_music("res://audio/music/battle_theme.ogg", 0.8)

func _on_battle_ended(victory: bool) -> void:
	battle_ui.hide_battle_ui()
	is_in_battle = false
	can_move = true
	
	if victory:
		enemies_defeated += 1
		
		# Check for boss defeat
		if secret_boss_unlocked and not secret_boss_defeated:
			secret_boss_defeated = true
			_on_boss_defeated()
		else:
			_show_victory_message()
			AudioManager.play_music("res://audio/music/ruins_light.ogg", 1.0)
	else:
		_show_defeat_message()

func _show_victory_message() -> void:
	is_in_dialogue = true
	var exp_gained = randi() % 5 + 3
	var gold_gained = randi() % 8 + 2
	
	GlobalVariables.character_stats["Frisk"]["exp"] += exp_gained
	GlobalVariables.add_gold(gold_gained)
	
	var lines = [
		{"speaker": "", "text": "* Victory!"},
		{"speaker": "", "text": "* You gained %d EXP." % exp_gained},
		{"speaker": "", "text": "* You gained %d GOLD." % gold_gained},
	]
	_start_dialogue_sequence(lines, "_end_dialogue")

func _show_defeat_message() -> void:
	is_in_dialogue = true
	var lines = [
		{"speaker": "", "text": "* You collapsed..."},
		{"speaker": "", "text": "* But you determined to try again."},
	]
	_start_dialogue_sequence(lines, "_respawn_player")

func _respawn_player() -> void:
	GlobalVariables.heal_full()
	GlobalVariables.set_flag("chapter1_intro_complete")
	_change_area(Area.RUINS_ENTRANCE)
	player.global_position = Vector2(640, 500)
	is_in_dialogue = false
	can_move = true

func _on_boss_defeated() -> void:
	is_in_dialogue = true
	can_move = false
	
	AudioManager.play_music("res://audio/music/ruins_light.ogg", 1.0)
	
	var lines = [
		{"speaker": "", "text": "* The SHADOW GUARDIAN crumbles!"},
		{"speaker": "", "text": "* The darkness disperses into the air..."},
		{"speaker": "", "text": "* The Dark Fountain begins to seal itself!"},
		{"speaker": "Toriel", "text": "You did it, my child!"},
		{"speaker": "Toriel", "text": "You sealed the Dark Fountain!"},
		{"speaker": "Toriel", "text": "The Underground is safe... for now."},
		{"speaker": "", "text": "* TORIEL joins your party!"},
		{"speaker": "", "text": "* CHAPTER 1 COMPLETE!"},
		{"speaker": "", "text": "* Thank you for playing!"},
	]
	
	GlobalVariables.add_to_party("Toriel")
	chapter_complete = true
	chapter_completed.emit()
	
	_start_dialogue_sequence(lines, "_show_credits")

func _show_credits() -> void:
	var lines = [
		{"speaker": "", "text": "================================"},
		{"speaker": "", "text": "UNDERTALE: DARK UNDERGROUND"},
		{"speaker": "", "text": "Chapter 1: The Dark Awakening"},
		{"speaker": "", "text": "================================"},
		{"speaker": "", "text": ""},
		{"speaker": "", "text": "A fan game inspired by"},
		{"speaker": "", "text": "UNDERTALE & DELTARUNE"},
		{"speaker": "", "text": "by Toby Fox"},
		{"speaker": "", "text": ""},
		{"speaker": "", "text": "Created with Godot Engine"},
		{"speaker": "", "text": ""},
		{"speaker": "", "text": "This is a FREE, NON-COMMERCIAL fangame."},
		{"speaker": "", "text": ""},
		{"speaker": "", "text": "Thank you for playing!"},
	]
	
	_start_dialogue_sequence(lines, "_end_game")

func _end_game() -> void:
	get_tree().change_scene_to_file("res://scenes/core/MainMenu.tscn")

func _change_area(door: Node2D) -> void:
	var target_area = door.get_meta("target_area")
	if target_area != null:
		_change_area_by_name(target_area)

func _change_area_by_name(area_name: String) -> void:
	match area_name:
		"RuinsEntrance":
			_change_area(Area.RUINS_ENTRANCE)
		"TorielHome":
			_change_area(Area.TORIEL_HOME)
		"PuzzleRoom":
			_change_area(Area.PUZZLE_ROOM)
		"DarkFountainRoom":
			_change_area(Area.DARK_FOUNTAIN_ROOM)
		"BossArena":
			_change_area(Area.BOSS_ARENA)

func _change_area(new_area: Area) -> void:
	_show_area(new_area)
	current_area = new_area
	
	if new_area not in areas_visited:
		areas_visited.append(new_area)
	
	area_changed.emit(Area.keys()[new_area])

func _show_area(area: Area) -> void:
	# Hide all areas
	for a in $Areas.get_children():
		a.visible = false
	
	# Show requested area
	match area:
		Area.RUINS_ENTRANCE:
			ruins_entrance.visible = true
		Area.TORIEL_HOME:
			toriel_home.visible = true
		Area.PUZZLE_ROOM:
			puzzle_room.visible = true
		Area.DARK_FOUNTAIN_ROOM:
			dark_room.visible = true
		Area.BOSS_ARENA:
			boss_arena.visible = true

func _save_game() -> void:
	is_in_dialogue = true
	can_move = false
	
	SaveSystem.save_game(0)
	
	var lines = [
		{"speaker": "", "text": "* You saved your progress."},
		{"speaker": "", "text": "* Determination stored..."},
	]
	_start_dialogue_sequence(lines, "_end_dialogue")

func _toggle_pause() -> void:
	is_paused = !is_paused
	pause_menu.visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		AudioManager.pause_music()
	else:
		AudioManager.resume_music()

func _start_dialogue_sequence(lines: Array, completion_callback: String) -> void:
	is_in_dialogue = true
	can_move = false
	
	var dialogue_data = {"lines": lines}
	DialogueManager.start_dialogue(dialogue_data)
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_done.bind(completion_callback))

func _on_dialogue_done(callback: String) -> void:
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_done)
	call(callback)

func _end_dialogue() -> void:
	is_in_dialogue = false
	can_move = true

func _on_player_interact(_target: Node2D) -> void:
	pass
