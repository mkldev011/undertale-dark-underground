extends Control

# BattleUI.gd
# Battle interface with command selection

signal action_selected(action: String, target: int)
signal spell_selected(spell_id: String)
signal item_selected(item_id: String)
signal act_selected(act_id: String)
signal enemy_targeted(index: int)

@onready var soul: Area2D = $BattleBox/Soul
@onready var hp_bar: ProgressBar = $HPContainer/HPBar
@onready var hp_label: Label = $HPContainer/HPLabel
@onready var name_label: Label = $HPContainer/NameLabel
@onready var tp_bar: ProgressBar = $TPContainer/TPBar
@onready var tp_label: Label = $TPContainer/TPLabel
@onready var menu_container: VBoxContainer = $MenuContainer
@onready var command_buttons: Array = []

# Command menu options
var main_commands: Array = ["FIGHT", "ACT", "ITEM", "MERCY"]
var act_commands: Array = []
var mercy_commands: Array = ["SPARE", "FLEE"]

# Battle state
var current_menu: String = "main"
var current_selection: int = 0
var selected_enemy_index: int = 0
var is_battle_active: bool = false

# Player soul position
var soul_speed: float = 5.0
var soul_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	hide()
	_setup_menu()

func _setup_menu() -> void:
	_update_menu_display()

func _process(_delta: float) -> void:
	if not is_battle_active:
		return
	
	# Handle soul movement during enemy turn
	if BattleManager.current_state == BattleManager.BattleState.BULLET_HELL:
		_handle_soul_movement()

func _handle_soul_movement() -> void:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")
	
	soul_velocity = input_dir * soul_speed * 60
	soul.position += soul_velocity
	
	# Clamp to battle box
	var battle_box = $BattleBox
	var bounds = battle_box.size - Vector2(20, 20)
	soul.position = soul.position.clamp(Vector2(10, 10), bounds)

func show_battle_ui() -> void:
	show()
	is_battle_active = true
	_show_main_menu()
	_update_hp_display()
	_update_tp_display()

func hide_battle_ui() -> void:
	hide()
	is_battle_active = false

func _update_hp_display() -> void:
	var hp = BattleManager.player_stats["hp"]
	var max_hp = BattleManager.player_stats["max_hp"]
	
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_label.text = "HP: %d/%d" % [hp, max_hp]

func _update_tp_display() -> void:
	var tp = BattleManager.current_tp
	var max_tp = BattleManager.max_tp
	
	tp_bar.max_value = max_tp
	tp_bar.value = tp
	tp_label.text = "TP: %d/%d" % [tp, max_tp]

func _show_main_menu() -> void:
	current_menu = "main"
	_update_menu_display()
	current_selection = 0

func _update_menu_display() -> void:
	for child in menu_container.get_children():
		child.queue_free()
	command_buttons.clear()
	
	var commands = _get_current_commands()
	
	for i in range(commands.size()):
		var button = Button.new()
		button.text = commands[i]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		var index = i
		button.pressed.connect(func(): _on_command_selected(index))
		
		menu_container.add_child(button)
		command_buttons.append(button)
	
	_update_selection_highlight()

func _get_current_commands() -> Array:
	match current_menu:
		"main":
			return main_commands
		"act":
			return act_commands
		"mercy":
			return mercy_commands
		"item":
			return GlobalVariables.inventory if not GlobalVariables.inventory.is_empty() else ["(No items)"]
		"spell":
			return ["HEAL", "FIRE", "ICE", "LIGHTNING", "BACK"]
		"target":
			return ["BACK"]
	return []

func _update_selection_highlight() -> void:
	for i in range(command_buttons.size()):
		var command = _get_current_commands()[i]
		if i == current_selection:
			command_buttons[i].text = ">%s" % command
		else:
			command_buttons[i].text = " %s" % command

func _input(event: InputEvent) -> void:
	if not is_battle_active:
		return
	
	if BattleManager.current_state != BattleManager.BattleState.PLAYER_TURN:
		return
	
	if event.is_action_pressed("ui_up"):
		current_selection = (current_selection - 1 + command_buttons.size()) % command_buttons.size()
		_update_selection_highlight()
		AudioManager.play_ui_move()
	elif event.is_action_pressed("ui_down"):
		current_selection = (current_selection + 1) % command_buttons.size()
		_update_selection_highlight()
		AudioManager.play_ui_move()
	elif event.is_action_pressed("ui_cancel"):
		_back_to_previous_menu()
	elif event.is_action_pressed("ui_accept"):
		_on_command_selected(current_selection)

func _on_command_selected(index: int) -> void:
	AudioManager.play_ui_confirm()
	
	var commands = _get_current_commands()
	var command = commands[index]
	
	match current_menu:
		"main":
			match command:
				"FIGHT":
					_enter_targeting_mode()
				"ACT":
					_enter_act_menu()
				"ITEM":
					_enter_item_menu()
				"MERCY":
					_enter_mercy_menu()
		"act":
			_choose_act_action(command)
		"mercy":
			_choose_mercy_action(command)
		"item":
			if GlobalVariables.has_item(command):
				_use_item(command)
		"spell":
			if command == "BACK":
				_show_main_menu()
			else:
				_cast_spell(command.to_lower())
		"target":
			_confirm_target()

func _enter_targeting_mode() -> void:
	current_menu = "target"
	current_selection = 0
	_update_menu_display()

func _enter_act_menu() -> void:
	act_commands.clear()
	if BattleManager.enemies.size() > 0:
		act_commands = ["TALK", "CHECK"]
	act_commands.append("BACK")
	
	current_menu = "act"
	_update_menu_display()

func _enter_item_menu() -> void:
	current_menu = "item"
	_update_menu_display()

func _enter_mercy_menu() -> void:
	current_menu = "mercy"
	_update_menu_display()

func _enter_spell_menu() -> void:
	current_menu = "spell"
	_update_menu_display()

func _back_to_previous_menu() -> void:
	if current_menu in ["act", "item", "mercy", "spell", "target"]:
		_show_main_menu()

func _confirm_target() -> void:
	if current_menu == "target":
		BattleManager.attack(current_selection)
		_update_hp_display()

func _choose_act_action(action: String) -> void:
	if action == "BACK":
		_show_main_menu()
		return
	
	var act_id = action.to_lower()
	BattleManager.act(act_id, 0)

func _choose_mercy_action(action: String) -> void:
	match action:
		"SPARE":
			BattleManager.spare(0)
		"FLEE":
			BattleManager.attempt_escape()

func _use_item(item_id: String) -> void:
	BattleManager.use_item(item_id)
	_update_hp_display()
	_show_main_menu()

func _cast_spell(spell_id: String) -> void:
	if BattleManager.use_magic(spell_id):
		_update_hp_display()
	_update_tp_display()
	_show_main_menu()

func show_damage_to_player(amount: int) -> void:
	var damage_label = Label.new()
	damage_label.text = str(amount)
	damage_label.global_position = soul.global_position + Vector2(-10, -30)
	damage_label.add_theme_font_size_override("font_size", 16)
	damage_label.z_index = 100
	
	add_child(damage_label)
	
	var original_color = soul.modulate
	soul.modulate = Color.RED
	
	var tween = create_tween()
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 30, 0.5)
	tween.tween_property(damage_label, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func():
		damage_label.queue_free()
		soul.modulate = original_color
	)

func _on_soul_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		BattleManager._player_hit()
		_update_hp_display()
		show_damage_to_player(BattleManager.player_stats["hp"])
		area.queue_free()

func _connect_battle_signals() -> void:
	BattleManager.player_damaged.connect(_on_player_damaged)
	BattleManager.tp_changed.connect(_on_tp_changed)
	BattleManager.battle_started.connect(_on_battle_started)
	BattleManager.battle_ended.connect(_on_battle_ended)
	BattleManager.turn_started.connect(_on_turn_started)

func _on_battle_started(enemies: Array) -> void:
	show_battle_ui()

func _on_battle_ended(victory: bool) -> void:
	hide_battle_ui()

func _on_player_damaged(amount: int) -> void:
	_update_hp_display()

func _on_tp_changed(new_tp: int) -> void:
	_update_tp_display()

func _on_turn_started(actor: String) -> void:
	if actor == "player":
		_show_main_menu()
