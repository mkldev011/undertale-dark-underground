extends Control

# TextBox.gd
# Undertale-style text box with typewriter effect

signal text_completed
signal choice_selected(index: int)
signal dialogue_finished

@export var text_speed: float = 0.03
@export var char_per_line: int = 55

# UI References
@onready var text_container: Panel = $TextContainer
@onready var name_box: Panel = $NameBox
@onready var name_label: Label = $NameBox/NameLabel
@onready var text_label: RichTextLabel = $TextContainer/MarginContainer/TextLabel
@onready var indicator: Sprite2D = $TextContainer/Indicator
@onready var choice_container: VBoxContainer = $ChoiceContainer

# State
var is_visible: bool = false
var current_text: String = ""
var displayed_text: String = ""
var full_text_length: int = 0
var char_index: int = 0
var is_waiting_for_input: bool = false
var is_complete: bool = false

# Typewriter state
var typewriter_timer: Timer
var typewriter_active: bool = false

# Choices
var current_choices: Array = []
var choice_buttons: Array = []
var current_choice_index: int = 0

# Speaker
var current_speaker: String = ""

func _ready() -> void:
	hide()
	
	# Setup timer for typewriter
	typewriter_timer = Timer.new()
	typewriter_timer.name = "TypewriterTimer"
	typewriter_timer.wait_time = text_speed
	typewriter_timer.one_shot = true
	typewriter_timer.timeout.connect(_on_typewriter_timeout)
	add_child(typewriter_timer)
	
	# Setup choice buttons (create on demand)
	choice_container.hide()

func _process(_delta: float) -> void:
	if not is_visible:
		return
	
	# Indicator animation
	if is_waiting_for_input and not current_choices.is_empty():
		indicator.visible = false
	elif is_waiting_for_input:
		indicator.visible = true
		indicator.position.y = text_label.global_position.y + text_label.size.y + 5
	else:
		indicator.visible = false
	
	# Handle input
	if Input.is_action_just_pressed("ui_accept"):
		_handle_input()

func _handle_input() -> void:
	if is_waiting_for_input:
		if not current_choices.is_empty():
			# Don't advance here, wait for choice
			return
		else:
			advance()
	else:
		# Skip typewriter effect
		complete_text()

# Show dialogue text
func show_text(text: String, speaker: String = "", choices: Array = []) -> void:
	is_visible = true
	show()
	
	current_speaker = speaker
	current_choices = choices
	
	# Setup speaker name
	if speaker != "":
		name_box.show()
		name_label.text = speaker
	else:
		name_box.hide()
	
	# Setup text
	current_text = text
	displayed_text = ""
	char_index = 0
	is_complete = false
	is_waiting_for_input = false
	
	# Setup choices
	if not choices.is_empty():
		_setup_choices(choices)
		choice_container.show()
	else:
		choice_container.hide()
	
	# Start typewriter
	_start_typewriter()

func _start_typewriter() -> void:
	typewriter_active = true
	typewriter_timer.start()

func _on_typewriter_timeout() -> void:
	if char_index < current_text.length():
		char_index += 1
		displayed_text = current_text.substr(0, char_index)
		text_label.text = displayed_text
		
		typewriter_timer.start()
	else:
		complete_text()

func complete_text() -> void:
	typewriter_timer.stop()
	typewriter_active = false
	displayed_text = current_text
	text_label.text = displayed_text
	is_complete = true
	
	if current_choices.is_empty():
		is_waiting_for_input = true
	else:
		_select_choice(current_choice_index)
	
	text_completed.emit()

func advance() -> void:
	if not is_complete:
		complete_text()
		return
	
	choice_container.hide()
	dialogue_finished.emit()
	hide()
	is_visible = false

func _setup_choices(choices: Array) -> void:
	# Clear existing choices
	for child in choice_container.get_children():
		child.queue_free()
	choice_buttons.clear()
	
	# Create choice buttons
	for i in range(choices.size()):
		var choice = choices[i]
		var button = Button.new()
		button.text = choice.get("text", "")
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		var index = i
		button.pressed.connect(func(): _on_choice_selected(index))
		
		choice_container.add_child(button)
		choice_buttons.append(button)
	
	current_choice_index = 0
	_update_choice_highlight()

func _update_choice_highlight() -> void:
	for i in range(choice_buttons.size()):
		if i == current_choice_index:
			choice_buttons[i].text = ">" + choice_buttons[i].text + "<"
		else:
			var base_text = current_choices[i].get("text", "")
			choice_buttons[i].text = " " + base_text + " "

func _select_choice(index: int) -> void:
	current_choice_index = index
	_update_choice_highlight()
	AudioManager.play_ui_select()

func _on_choice_selected(index: int) -> void:
	AudioManager.play_ui_confirm()
	choice_selected.emit(index)
	choice_container.hide()
	dialogue_finished.emit()
	hide()
	is_visible = false

# Navigate choices with keyboard
func _input(event: InputEvent) -> void:
	if not is_visible or current_choices.is_empty():
		return
	
	if event.is_action_pressed("ui_up"):
		current_choice_index = (current_choice_index - 1 + choice_buttons.size()) % choice_buttons.size()
		_update_choice_highlight()
		AudioManager.play_ui_move()
	elif event.is_action_pressed("ui_down"):
		current_choice_index = (current_choice_index + 1) % choice_buttons.size()
		_update_choice_highlight()
		AudioManager.play_ui_move()

# Utility
func set_text_speed(speed: float) -> void:
	text_speed = speed
	typewriter_timer.wait_time = speed

func set_custom_chars_per_line(chars: int) -> void:
	char_per_line = chars
