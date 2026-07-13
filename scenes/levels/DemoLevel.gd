extends Node2D

# DemoLevel.gd
# Simple demo level to test battle system

@onready var player: CharacterBody2D = $Player
@onready var text_box: Control = $TextBox
@onready var battle_ui: Control = $BattleUI

var is_in_battle: bool = false
var demo_dialogue_shown: bool = false

func _ready() -> void:
	# Connect to battle manager
	BattleManager.battle_started.connect(_on_battle_started)
	BattleManager.battle_ended.connect(_on_battle_ended)
	
	# Show intro dialogue
	if not demo_dialogue_shown:
		_show_intro()

func _show_intro() -> void:
	demo_dialogue_shown = true
	
	var dialogue_data = {
		"lines": [
			{"text": "* Welcome to Dark Underground!", "speaker": "Narrator"},
			{"text": "* This is a demo of the battle system.", "speaker": "Narrator"},
			{"text": "* Walk into the red marker to start a battle.", "speaker": "Narrator"}
		]
	}
	
	DialogueManager.start_dialogue(dialogue_data)

func _process(_delta: float) -> void:
	if is_in_battle:
		return
	
	# Check for battle trigger
	var enemies_in_area = $BattleTrigger.get_overlapping_bodies()
	if not enemies_in_area.is_empty() and not is_in_battle:
		_start_demo_battle()

func _start_demo_battle() -> void:
	is_in_battle = true
	
	# Demo enemy data
	var enemy_data = [
		{
			"id": "dummy",
			"name": "Training Dummy",
			"hp": 30,
			"max_hp": 30,
			"attack": 5,
			"defense": 3,
			"attack_pattern": {"name": "Hit", "damage": 5, "bullets": 3, "pattern": "spread"},
			"can_spare": true,
			"spare_requirements": [],
			"description": "A simple training dummy."
		}
	]
	
	BattleManager.start_battle(enemy_data, ["Frisk"])

func _on_battle_started(enemies: Array) -> void:
	battle_ui.show_battle_ui()
	player.hide()
	is_in_battle = true

func _on_battle_ended(victory: bool) -> void:
	battle_ui.hide_battle_ui()
	player.show()
	is_in_battle = false
	
	if victory:
		var dialogue = {
			"lines": [
				{"text": "* You won the battle!", "speaker": "Narrator"},
				{"text": "* The dummy was defeated.", "speaker": "Narrator"}
			]
		}
		DialogueManager.start_dialogue(dialogue)
	else:
		var dialogue = {
			"lines": [
				{"text": "* You were defeated...", "speaker": "Narrator"},
				{"text": "* But this is just a demo!", "speaker": "Narrator"}
			]
		}
		DialogueManager.start_dialogue(dialogue)
