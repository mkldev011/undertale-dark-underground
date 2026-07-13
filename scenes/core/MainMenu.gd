extends Control

# MainMenu.gd
# Main menu screen

signal menu_option_selected(option: String)

@onready var title_label: Label = $VBoxContainer/TitleContainer/TitleLabel
@onready var version_label: Label = $VBoxContainer/TitleContainer/VersionLabel
@onready var menu_options: VBoxContainer = $VBoxContainer/MenuContainer/MenuOptions
@onready var menu_buttons: Array = []

var current_selection: int = 0
var is_selecting: bool = true

# Menu options
var options: Array = ["START", "CONTINUE", "OPTIONS", "CREDITS", "QUIT"]
var can_continue: bool = false

func _ready() -> void:
	_setup_menu()
	_update_selection()
	
	# Check if save exists
	can_continue = SaveSystem.save_exists(0)

func _setup_menu() -> void:
	# Clear existing buttons
	for child in menu_options.get_children():
		child.queue_free()
	menu_buttons.clear()
	
	# Create buttons for each option
	for i in range(options.size()):
		var option = options[i]
		
		# Skip CONTINUE if no save exists
		if option == "CONTINUE" and not can_continue:
			continue
		
		var button = Button.new()
		button.text = option
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.add_theme_font_size_override("font_size", 24)
		
		# Connect button
		var index = menu_buttons.size()
		button.pressed.connect(func(): _on_option_selected(index))
		
		menu_options.add_child(button)
		menu_buttons.append(button)

func _process(_delta: float) -> void:
	if not is_selecting:
		return
	
	# Handle menu navigation
	if Input.is_action_just_pressed("ui_up"):
		_change_selection(-1)
	elif Input.is_action_just_pressed("ui_down"):
		_change_selection(1)
	elif Input.is_action_pressed("ui_accept"):
		_on_option_selected(current_selection)

func _change_selection(direction: int) -> void:
	current_selection = (current_selection + direction) % menu_buttons.size()
	_update_selection()
	AudioManager.play_ui_move()

func _update_selection() -> void:
	for i in range(menu_buttons.size()):
		if i == current_selection:
			menu_buttons[i].text = "> " + menu_buttons[i].text + " <"
		else:
			var base_text = options[i]
			if options[i] == "CONTINUE" and not can_continue:
				base_text = "CONTINUE"
			menu_buttons[i].text = "  " + base_text + "  "

func _on_option_selected(index: int) -> void:
	if index >= menu_buttons.size():
		return
	
	is_selecting = false
	AudioManager.play_ui_confirm()
	
	var option_text = menu_buttons[index].text.strip_edges().replace("> ", "").replace(" <", "")
	
	match option_text:
		"START":
			_start_new_game()
		"CONTINUE":
			_continue_game()
		"OPTIONS":
			_open_options()
		"CREDITS":
			_open_credits()
		"QUIT":
			_quit_game()

func _start_new_game() -> void:
	# Delete existing save
	SaveSystem.delete_save(0)
	GlobalVariables.reset_all_progress()
	
	# Start from beginning
	GameManager.change_scene("res://scenes/levels/Chapter1.tscn")
	GameManager.set_state(GameManager.GameState.PLAYING)

func _continue_game() -> void:
	var save_data = SaveSystem.load_game(0)
	if save_data.is_empty():
		return
	
	SaveSystem.apply_save_data(save_data)
	GameManager.set_state(GameManager.GameState.PLAYING)

func _open_options() -> void:
	# For now, just toggle fullscreen
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if get_window().mode != Window.MODE_EXCLUSIVE_FULLSCREEN else Window.MODE_WINDOWED

func _open_credits() -> void:
	# Show credits screen
	GameManager.change_scene("res://scenes/core/Credits.tscn")

func _quit_game() -> void:
	GameManager.quit_game()
