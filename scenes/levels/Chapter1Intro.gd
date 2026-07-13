extends Node2D

# Chapter1Intro.gd
# Chapter 1 Opening - The Dark Awakening

@onready var text_box: Control = $TextBox
@onready var background: ColorRect = $Background
@onready var fade_overlay: ColorRect = $FadeOverlay

var dialogue_index: int = 0
var is_dialogue_active: bool = false
var can_advance: bool = false

# Story dialogue
var intro_dialogue: Array = [
	{"speaker": "", "text": "Long ago, monsters lived in peace beneath the earth.", "bg_color": Color(0.1, 0.05, 0.15), "text_color": Color(0.9, 0.9, 0.9)},
	{"speaker": "", "text": "They called this place... the Underground.", "bg_color": Color(0.1, 0.05, 0.15), "text_color": Color(0.9, 0.9, 0.9)},
	{"speaker": "", "text": "For years, they waited for a human to fall down.", "bg_color": Color(0.05, 0.1, 0.15), "text_color": Color(0.9, 0.9, 0.9)},
	{"speaker": "", "text": "But what they got... was something else entirely.", "bg_color": Color(0.05, 0.1, 0.15), "text_color": Color(0.9, 0.9, 0.9)},
	{"speaker": "", "text": "* In the depths of the Underground, something stirred...", "bg_color": Color(0.05, 0.02, 0.1), "text_color": Color(0.7, 0.5, 0.9)},
	{"speaker": "", "text": "* A tear in reality itself began to form...", "bg_color": Color(0.05, 0.02, 0.1), "text_color": Color(0.7, 0.5, 0.9)},
	{"speaker": "", "text": "* And from it... darkness poured forth.", "bg_color": Color(0.02, 0.02, 0.05), "text_color": Color(0.5, 0.3, 0.8)},
	{"speaker": "", "text": "* They called them... Dark Fountains.", "bg_color": Color(0.02, 0.02, 0.05), "text_color": Color(0.5, 0.3, 0.8)},
	{"speaker": "???", "text": "What... what is this feeling?", "bg_color": Color(0.1, 0.15, 0.2), "text_color": Color(0.6, 0.8, 1)},
	{"speaker": "???", "text": "The shadows... they're growing.", "bg_color": Color(0.1, 0.15, 0.2), "text_color": Color(0.6, 0.8, 1)},
	{"speaker": "???", "text": "I must inform Asgore about this.", "bg_color": Color(0.1, 0.15, 0.2), "text_color": Color(0.6, 0.8, 1)},
	{"speaker": "???", "text": "And quickly...", "bg_color": Color(0.1, 0.15, 0.2), "text_color": Color(0.6, 0.8, 1)},
	{"speaker": "", "text": "* Somewhere in the Ruins, Toriel felt a chill.", "bg_color": Color(0.2, 0.1, 0.1), "text_color": Color(1, 0.8, 0.8)},
	{"speaker": "Toriel", "text": "What was that?", "bg_color": Color(0.2, 0.1, 0.1), "text_color": Color(1, 0.8, 0.8)},
	{"speaker": "Toriel", "text": "Something... something dark just passed through.", "bg_color": Color(0.2, 0.1, 0.1), "text_color": Color(1, 0.8, 0.8)},
	{"speaker": "Toriel", "text": "I should check on the children...", "bg_color": Color(0.2, 0.1, 0.1), "text_color": Color(1, 0.8, 0.8)},
	{"speaker": "", "text": "* In Snowdin, a skeleton looked toward the darkness...", "bg_color": Color(0.15, 0.2, 0.25), "text_color": Color(0.8, 0.9, 1)},
	{"speaker": "Sans", "text": "heh.", "bg_color": Color(0.15, 0.2, 0.25), "text_color": Color(0.8, 0.9, 1)},
	{"speaker": "Sans", "text": "looks like things are getting... darker.", "bg_color": Color(0.15, 0.2, 0.25), "text_color": Color(0.8, 0.9, 1)},
	{"speaker": "Sans", "text": "papyrus, you're gonna want to see this.", "bg_color": Color(0.15, 0.2, 0.25), "text_color": Color(0.8, 0.9, 1)},
	{"speaker": "Papyrus", "text": "NYEH?! WHAT IS IT, SANS?!", "bg_color": Color(0.15, 0.2, 0.25), "text_color": Color(1, 0.8, 0.5)},
	{"speaker": "Sans", "text": "the sky's turning purple, bro.", "bg_color": Color(0.15, 0.2, 0.25), "text_color": Color(0.8, 0.9, 1)},
	{"speaker": "Papyrus", "text": "...I SEE NOTHING UNUSUAL ABOUT THAT.", "bg_color": Color(0.15, 0.2, 0.25), "text_color": Color(1, 0.8, 0.5)},
	{"speaker": "Sans", "text": "that's the problem.", "bg_color": Color(0.15, 0.2, 0.25), "text_color": Color(0.8, 0.9, 1)},
	{"speaker": "", "text": "* The Dark Fountain spread its influence...", "bg_color": Color(0.08, 0.02, 0.15), "text_color": Color(0.7, 0.5, 0.9)},
	{"speaker": "", "text": "* Transforming the familiar into the unknown...", "bg_color": Color(0.08, 0.02, 0.15), "text_color": Color(0.7, 0.5, 0.9)},
	{"speaker": "", "text": "* The Underground would never be the same.", "bg_color": Color(0.05, 0.02, 0.1), "text_color": Color(0.7, 0.5, 0.9)},
	{"speaker": "", "text": "", "bg_color": Color.BLACK, "text_color": Color.BLACK},
	{"speaker": "", "text": "", "bg_color": Color.BLACK, "text_color": Color.BLACK},
	{"speaker": "Title", "text": "CHAPTER 1: THE DARK AWAKENING", "bg_color": Color.BLACK, "text_color": Color(0.9, 0.3, 0.3), "is_title": true},
	{"speaker": "", "text": "", "bg_color": Color.BLACK, "text_color": Color.BLACK},
]

func _ready() -> void:
	fade_overlay.color = Color.BLACK
	fade_overlay.visible = true
	
	# Start fade in
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 1.5)
	tween.finished.connect(_on_fade_in_complete)

func _on_fade_in_complete() -> void:
	fade_overlay.visible = false
	_start_dialogue()

func _start_dialogue() -> void:
	is_dialogue_active = true
	_show_line(0)

func _show_line(index: int) -> void:
	if index >= intro_dialogue.size():
		_end_intro()
		return
	
	dialogue_index = index
	var line = intro_dialogue[index]
	
	# Update background
	var tween = create_tween()
	tween.tween_property(background, "color", line["bg_color"], 0.5)
	
	# Show text
	text_box.show_text(line["text"], line["speaker"])
	can_advance = true

func _process(_delta: float) -> void:
	if not is_dialogue_active:
		return
	
	if can_advance and Input.is_action_just_pressed("ui_accept"):
		can_advance = false
		_advance_dialogue()

func _advance_dialogue() -> void:
	var line = intro_dialogue[dialogue_index]
	
	# Handle title screen
	if line.get("is_title", false):
		_show_title_effect()
		return
	
	dialogue_index += 1
	
	if dialogue_index >= intro_dialogue.size():
		_end_intro()
	else:
		_show_line(dialogue_index)

func _show_title_effect() -> void:
	# Dramatic title display
	fade_overlay.visible = true
	fade_overlay.color = Color.BLACK
	
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(fade_overlay, "color:a", 1.0, 1.0)
	tween.finished.connect(_end_intro)

func _end_intro() -> void:
	is_dialogue_active = false
	
	# Transition to Chapter 1 level
	GameManager.transition_to_scene("res://scenes/levels/Chapter1.tscn")
