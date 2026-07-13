extends Node

# DialogueManager.gd
# Handles all dialogue/text box functionality with typewriter effect

signal dialogue_started
signal dialogue_ended
signal dialogue_line_finished
signal choice_made(choice_index: int)
signal text_speed_changed

const DEFAULT_TEXT_SPEED = 0.03  # Seconds per character

var is_dialogue_active: bool = false
var current_dialogue_data: Dictionary = {}
var current_line_index: int = 0
var current_text: String = ""
var displayed_text: String = ""
var text_timer: Timer
var text_speed: float = DEFAULT_TEXT_SPEED

# Dialogue queue for multiple lines
var dialogue_queue: Array[Dictionary] = []

# Special text markers
var _skip_next_ticker: bool = false

func _ready() -> void:
	text_speed = GameManager.text_speed

# Start a dialogue sequence
func start_dialogue(dialogue_data: Dictionary) -> void:
	if is_dialogue_active:
		dialogue_queue.append(dialogue_data)
		return
	
	current_dialogue_data = dialogue_data
	current_line_index = 0
	is_dialogue_active = true
	
	# Load first line
	_load_line(current_line_index)
	dialogue_started.emit()

# Load and display a specific line
func _load_line(index: int) -> void:
	var lines = current_dialogue_data.get("lines", [])
	if index >= lines.size():
		_end_dialogue()
		return
	
	var line_data = lines[index]
	current_text = _process_text(line_data.get("text", ""))
	displayed_text = ""
	
	# Emit speaker info
	if line_data.has("speaker"):
		# This can be used to change portraits, etc.
		pass
	
	# Start typewriter effect
	_start_typewriter()

# Process text with special markers
func _process_text(text: String) -> String:
	# Process special markers like * [Wave] [Shake] [Color:X]
	var processed = text
	# Add your text processing logic here
	return processed

# Typewriter effect
func _start_typewriter() -> void:
	if not has_node("TextTimer"):
		text_timer = Timer.new()
		text_timer.name = "TextTimer"
		add_child(text_timer)
	
	text_timer.stop()
	
	# Use frames instead of timer for more control
	var chars = current_text.to_utf8_buffer()
	var char_index = 0
	
	while char_index < chars.size() and is_dialogue_active:
		displayed_text = current_text.substr(0, char_index + 1)
		dialogue_line_finished.emit()
		
		await get_tree().create_timer(text_speed * (1.0 / GameManager.text_speed)).timeout
		char_index += 1
	
	# Text complete
	displayed_text = current_text
	dialogue_line_finished.emit()

# Advance dialogue (call this when player presses confirm)
func advance_dialogue() -> void:
	if not is_dialogue_active:
		return
	
	# Check if text is still typing - if so, complete it instantly
	if displayed_text != current_text:
		displayed_text = current_text
		dialogue_line_finished.emit()
		return
	
	# Move to next line
	current_line_index += 1
	_load_line(current_line_index)

# Skip entire dialogue
func skip_dialogue() -> void:
	_end_dialogue()

# End current dialogue
func _end_dialogue() -> void:
	is_dialogue_active = false
	displayed_text = ""
	current_dialogue_data = {}
	dialogue_ended.emit()
	
	# Process queue
	if not dialogue_queue.is_empty():
		var next = dialogue_queue.pop_front()
		start_dialogue(next)

# Check if there's a choice in current line
func has_choice() -> bool:
	var lines = current_dialogue_data.get("lines", [])
	if current_line_index >= lines.size():
		return false
	return lines[current_line_index].has("choices")

# Get current choices
func get_choices() -> Array:
	var lines = current_dialogue_data.get("lines", [])
	if current_line_index >= lines.size():
		return []
	
	var line = lines[current_line_index]
	if line.has("choices"):
		return line["choices"]
	return []

# Make a choice
func make_choice(choice_index: int) -> void:
	var choices = get_choices()
	if choice_index >= choices.size():
		return
	
	choice_made.emit(choice_index)
	
	var choice_data = choices[choice_index]
	
	# Check for choice-specific next line
	if choice_data.has("next"):
		current_line_index = choice_data["next"]
		_load_line(current_line_index)
	else:
		advance_dialogue()

# Get current displayed text
func get_current_text() -> String:
	return displayed_text

# Get full text without typewriter
func get_full_text() -> String:
	return current_text

# Pause/resume dialogue
func pause_dialogue() -> void:
	if has_node("TextTimer"):
		get_node("TextTimer").stop()

func resume_dialogue() -> void:
	if has_node("TextTimer"):
		get_node("TextTimer").start(text_speed)

# Load dialogue from JSON file
func load_dialogue_from_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		push_error("Dialogue file not found: " + file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_line()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) == OK:
		return json.data
	return {}

# Save dialogue to JSON file (for editors)
func save_dialogue_to_file(file_path: String, dialogue_data: Dictionary) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false
	
	var json_string = JSON.stringify(dialogue_data, "\t")
	file.store_line(json_string)
	file.close()
	return true
