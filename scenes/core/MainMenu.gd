extends Control

# MainMenu.gd
# Dark Fantasy Main Menu with Chapter Selection

signal menu_option_selected(option: String)

# Menu state
enum MenuState {
	TITLE,
	CHAPTER_SELECT,
	OPTIONS,
	CREDITS
}

var current_state: MenuState = MenuState.TITLE
var current_selection: int = 0
var is_selecting: bool = true
var can_continue: bool = false

# UI References
@onready var title_container: VBoxContainer
@onready var main_menu_container: VBoxContainer
@onready var chapter_select_container: VBoxContainer
@onready var options_container: VBoxContainer
@onready var credits_container: VBoxContainer
@onready var version_label: Label
@onready var menu_buttons: Array = []
@onready var chapter_buttons: Array = []

# Animation
var menu_fade_in: bool = false
var fade_alpha: float = 0.0

# Chapter data
var chapters: Array = [
	{"id": 1, "name": "THE DARK AWAKENING", "desc": "Strange fountains of darkness appear...", "unlocked": true, "completed": false},
	{"id": 2, "name": "THE SHADOW'S EDGE", "desc": "The darkness spreads beyond the ruins...", "unlocked": false, "completed": false},
	{"id": 3, "name": "CHAOS REIGNS", "desc": "Multiple fountains threaten the Underground...", "unlocked": false, "completed": false}
]

func _ready() -> void:
	# Set up references
	title_container = $VBoxContainer
	main_menu_container = $MainMenuContainer
	chapter_select_container = $ChapterSelectContainer
	options_container = $OptionsContainer
	credits_container = $CreditsContainer
	version_label = $VersionLabel
	
	# Load save data
	_load_save_data()
	
	# Set up menus
	_setup_main_menu()
	_update_visibility()
	
	# Start music
	AudioManager.play_music("res://audio/music/dark_fantasy_menu.ogg", 1.0)
	
	# Animate fade in
	modulate.a = 0.0
	menu_fade_in = true

func _load_save_data() -> void:
	can_continue = SaveSystem.save_exists(0)
	
	# Check for chapter progress
	var save_data = SaveSystem.load_data("user://settings.sav")
	if save_data:
		var completed_chapters = save_data.get("completed_chapters", [])
		for i in range(chapters.size()):
			if chapters[i]["id"] in completed_chapters:
				chapters[i]["completed"] = true
			# Unlock next chapter if previous completed
			if i > 0 and chapters[i-1]["completed"]:
				chapters[i]["unlocked"] = true

func _process(delta: float) -> void:
	# Fade in animation
	if menu_fade_in:
		fade_alpha += delta * 2.0
		modulate.a = min(fade_alpha, 1.0)
		if fade_alpha >= 1.0:
			menu_fade_in = false
	
	if not is_selecting:
		return
	
	# Handle menu navigation
	if Input.is_action_just_pressed("ui_up"):
		_change_selection(-1)
		AudioManager.play_ui_move()
	elif Input.is_action_just_pressed("ui_down"):
		_change_selection(1)
		AudioManager.play_ui_move()
	elif Input.is_action_just_pressed("ui_accept"):
		_select_current()
		AudioManager.play_ui_confirm()
	elif Input.is_action_just_pressed("ui_cancel"):
		_go_back()
		AudioManager.play_ui_cancel()

func _change_selection(direction: int) -> void:
	match current_state:
		MenuState.TITLE:
			var max_sel = 3 if can_continue else 2
			current_selection = (current_selection + direction + max_sel + 1) % (max_sel + 1)
		MenuState.CHAPTER_SELECT:
			var max_sel = chapters.filter(func(c): return c["unlocked"]).size() - 1
			current_selection = (current_selection + direction + max_sel + 1) % (max_sel + 1)
		MenuState.OPTIONS:
			current_selection = (current_selection + direction + 3) % 3
		MenuState.CREDITS:
			current_selection = 0
	
	_update_buttons()

func _select_current() -> void:
	match current_state:
		MenuState.TITLE:
			_select_main_menu()
		MenuState.CHAPTER_SELECT:
			_start_chapter()
		MenuState.OPTIONS:
			_handle_options()
		MenuState.CREDITS:
			pass

func _go_back() -> void:
	match current_state:
		MenuState.CHAPTER_SELECT:
			current_state = MenuState.TITLE
			current_selection = 0
		MenuState.OPTIONS:
			current_state = MenuState.TITLE
			current_selection = 0
		MenuState.CREDITS:
			current_state = MenuState.TITLE
			current_selection = 0
	
	_update_visibility()

func _select_main_menu() -> void:
	match current_selection:
		0: # Start / Chapter Select
			current_state = MenuState.CHAPTER_SELECT
			current_selection = 0
		1: # Continue
			if can_continue:
				_continue_game()
		2: # Options
			current_state = MenuState.OPTIONS
			current_selection = 0
		3: # Credits
			current_state = MenuState.CREDITS
		4: # Quit
			_quit_game()
	
	_update_visibility()

func _setup_main_menu() -> void:
	# Clear and set up main menu buttons
	for child in main_menu_container.get_children():
		child.queue_free()
	menu_buttons.clear()
	
	var options = ["CHAPTER SELECT"]
	if can_continue:
		options.append("CONTINUE")
	options.append("OPTIONS")
	options.append("CREDITS")
	options.append("QUIT")
	
	for i in range(options.size()):
		var btn = _create_menu_button(options[i])
		btn.pressed.connect(func(): _on_main_menu_select(i))
		main_menu_container.add_child(btn)
		menu_buttons.append(btn)
	
	# Set up chapter buttons
	for child in chapter_select_container.get_children():
		child.queue_free()
	chapter_buttons.clear()
	
	for i in range(chapters.size()):
		var chapter = chapters[i]
		var btn = _create_chapter_button(chapter)
		btn.pressed.connect(func(): _on_chapter_select(i))
		chapter_select_container.add_child(btn)
		chapter_buttons.append(btn)
	
	# Set up options
	_setup_options()
	
	# Set up credits
	_setup_credits()
	
	_update_buttons()

func _create_menu_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.add_theme_font_size_override("font_size", 28)
	btn.custom_minimum_size.y = 50
	return btn

func _create_chapter_button(chapter: Dictionary) -> Button:
	var btn = Button.new()
	btn.text = "[%d] %s" % [chapter["id"], chapter["name"]]
	if not chapter["unlocked"]:
		btn.text = "[X] LOCKED"
		btn.disabled = true
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 24)
	btn.custom_minimum_size.y = 60
	return btn

func _setup_options() -> void:
	for child in options_container.get_children():
		child.queue_free()
	
	# Volume controls
	var volume_label = Label.new()
	volume_label.text = "VOLUME"
	volume_label.add_theme_font_size_override("font_size", 20)
	options_container.add_child(volume_label)
	
	var music_vol = _create_option_slider("MUSIC: ", GameManager.music_volume)
	var sfx_vol = _create_option_slider("SFX: ", GameManager.sfx_volume)
	options_container.add_child(music_vol)
	options_container.add_child(sfx_vol)

func _create_option_slider(label_text: String, value: float) -> HBoxContainer:
	var container = HBoxContainer.new()
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 150
	container.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.1
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(slider)
	
	return container

func _setup_credits() -> void:
	for child in credits_container.get_children():
		child.queue_free()
	
	var credits_text = [
		"",
		"UNDERTALE: DARK UNDERGROUND",
		"",
		"A fan game inspired by:",
		"UNDERTALE & DELTARUNE",
		"by Toby Fox",
		"",
		"",
		"Created with Godot Engine",
		"",
		"",
		"This is a FREE, NON-COMMERCIAL fangame.",
		"No monetization. No ads. No donations.",
		"",
		"Credit to Toby Fox for the inspiration.",
		"",
		"",
		"© Toby Fox. Undertale and Deltarune",
		"are registered trademarks of Toby Fox.",
		"",
	]
	
	for line in credits_text:
		var label = Label.new()
		label.text = line
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 18)
		credits_container.add_child(label)

func _update_buttons() -> void:
	match current_state:
		MenuState.TITLE:
			for i in range(menu_buttons.size()):
				var text = menu_buttons[i].text.strip_edges()
				if text == "QUIT":
					text = ""
				if i == current_selection:
					menu_buttons[i].text = "> " + text + " <" if text else "> QUIT <"
				else:
					menu_buttons[i].text = "  " + text + "  " if text else "  QUIT  "
		
		MenuState.CHAPTER_SELECT:
			for i in range(chapter_buttons.size()):
				var chapter = chapters[i]
				var prefix = "[%d]" % chapter["id"]
				if not chapter["unlocked"]:
					prefix = "[X]"
				
				if i == current_selection and chapter["unlocked"]:
					chapter_buttons[i].text = "> " + prefix + " " + chapter["name"]
				elif chapter["unlocked"]:
					chapter_buttons[i].text = "  " + prefix + " " + chapter["name"]
				else:
					chapter_buttons[i].text = "    " + prefix + " LOCKED"

func _update_visibility() -> void:
	main_menu_container.visible = current_state == MenuState.TITLE
	chapter_select_container.visible = current_state == MenuState.CHAPTER_SELECT
	options_container.visible = current_state == MenuState.OPTIONS
	credits_container.visible = current_state == MenuState.CREDITS
	_update_buttons()

func _on_main_menu_select(index: int) -> void:
	current_selection = index
	_select_main_menu()

func _on_chapter_select(index: int) -> void:
	if not chapters[index]["unlocked"]:
		return
	current_selection = index
	_start_chapter()

func _start_chapter() -> void:
	var chapter = chapters[current_selection]
	GlobalVariables.current_chapter = chapter["id"]
	
	# Start the chapter
	match chapter["id"]:
		1:
			_start_new_game()
		2:
			_start_new_game()
		3:
			_start_new_game()

func _handle_options() -> void:
	# Simple fullscreen toggle
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if get_window().mode != Window.MODE_EXCLUSIVE_FULLSCREEN else Window.MODE_WINDOWED

func _start_new_game() -> void:
	SaveSystem.delete_save(0)
	GlobalVariables.reset_all_progress()
	GlobalVariables.current_chapter = 1
	
	# Transition to intro
	GameManager.transition_to_scene("res://scenes/levels/Chapter1Intro.tscn")

func _continue_game() -> void:
	var save_data = SaveSystem.load_game(0)
	if save_data.is_empty():
		return
	
	SaveSystem.apply_save_data(save_data)
	GameManager.set_state(GameManager.GameState.PLAYING)
	
	var scene_path = "res://scenes/levels/Chapter%d.tscn" % GlobalVariables.current_chapter
	GameManager.change_scene(scene_path)

func _quit_game() -> void:
	SaveSystem.save_settings()
	get_tree().quit()
