extends Control

# MainMenu.gd - Complete Main Menu with Play, Settings, Credits

signal menu_action(action: String)

# Menu states
enum MenuState {
	MAIN,
	CHAPTER_SELECT,
	SETTINGS,
	CREDITS
}

var current_state: MenuState = MenuState.MAIN
var selected_index: int = 0
var is_animating: bool = false

# Settings
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.8
var fullscreen: bool = false
var text_speed: float = 1.0
var battle_speed: float = 1.0

@onready var title_label: Label = $TitleContainer/TitleLabel
@onready var subtitle_label: Label = $TitleContainer/SubtitleLabel
@onready var menu_container: VBoxContainer = $MenuContainer
@onready var settings_container: VBoxContainer = $SettingsContainer
@onready var credits_scroll: ScrollContainer = $CreditsContainer/CreditsScroll
@onready var credits_label: Label = $CreditsContainer/CreditsScroll/CreditsLabel
@onready var chapter_container: VBoxContainer = $ChapterContainer
@onready var version_label: Label = $VersionLabel
@onready var fade_rect: ColorRect = $FadeRect
@onready var soul_sprite: Sprite2D = $TitleContainer/SoulSprite

func _ready() -> void:
	_load_settings()
	_show_main_menu()
	_play_animation()

func _load_settings() -> void:
	if FileAccess.file_exists("user://settings.cfg"):
		var config = ConfigFile.new()
		if config.load("user://settings.cfg") == OK:
			master_volume = config.get_value("audio", "master", 1.0)
			music_volume = config.get_value("audio", "music", 0.8)
			sfx_volume = config.get_value("audio", "sfx", 0.8)
			fullscreen = config.get_value("display", "fullscreen", false)
			text_speed = config.get_value("game", "text_speed", 1.0)
			battle_speed = config.get_value("game", "battle_speed", 1.0)

func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("game", "text_speed", text_speed)
	config.set_value("game", "battle_speed", battle_speed)
	config.save("user://settings.cfg")

func _play_animation() -> void:
	# Floating soul animation
	var tween = create_tween().set_loops()
	tween.tween_property(soul_sprite, "position:y", -75, 1.0)
	tween.tween_property(soul_sprite, "position:y", -85, 1.0)

func _show_main_menu() -> void:
	_hide_all()
	current_state = MenuState.MAIN
	$TitleContainer.visible = true
	menu_container.visible = true
	
	_update_main_menu_buttons()

func _show_settings() -> void:
	_hide_all()
	current_state = MenuState.SETTINGS
	$SettingsTitle.visible = true
	settings_container.visible = true
	_update_settings_display()

func _show_credits() -> void:
	_hide_all()
	current_state = MenuState.CREDITS
	$CreditsTitle.visible = true
	credits_scroll.visible = true
	_update_credits_display()

func _show_chapter_select() -> void:
	_hide_all()
	current_state = MenuState.CHAPTER_SELECT
	$ChapterTitle.visible = true
	chapter_container.visible = true
	_update_chapter_display()

func _hide_all() -> void:
	$TitleContainer.visible = false
	menu_container.visible = false
	settings_container.visible = false
	$SettingsTitle.visible = false
	credits_scroll.visible = false
	$CreditsTitle.visible = false
	$ChapterTitle.visible = false
	chapter_container.visible = false

func _update_main_menu_buttons() -> void:
	for child in menu_container.get_children():
		child.queue_free()
	
	var items = [
		{"text": "> JUGAR", "action": "_start_game"},
		{"text": "  AJUSTES", "action": "_show_settings"},
		{"text": "  CRÉDITOS", "action": "_show_credits"},
		{"text": "  SALIR", "action": "_quit_game"}
	]
	
	for i in items.size():
		var btn = Button.new()
		btn.text = items[i]["text"]
		btn.custom_minimum_size = Vector2(350, 60)
		btn.add_theme_font_size_override("font_size", 28)
		btn.pressed.connect(_on_main_button_selected.bind(items[i]["action"]))
		menu_container.add_child(btn)
		
		# Highlight selected
		if i == selected_index:
			btn.text = "> " + btn.text.replace("  ", "").replace(">", "")

func _update_settings_display() -> void:
	for child in settings_container.get_children():
		child.queue_free()
	
	var settings_items = [
		{"text": "VOLUMEN GENERAL: %d%%" % int(master_volume * 100), "action": "vol_master"},
		{"text": "VOLUMEN MÚSICA: %d%%" % int(music_volume * 100), "action": "vol_music"},
		{"text": "VOLUMEN EFECTOS: %d%%" % int(sfx_volume * 100), "action": "vol_sfx"},
		{"text": "PANTALLA COMPLETA: %s" % ("SÍ" if fullscreen else "NO"), "action": "toggle_fullscreen"},
		{"text": "VELOCIDAD TEXTO: %.1fx" % text_speed, "action": "text_speed"},
		{"text": "VELOCIDAD BATALLA: %.1fx" % battle_speed, "action": "battle_speed"},
		{"text": "", "action": ""},
		{"text": "> VOLVER AL MENÚ", "action": "_show_main_menu"}
	]
	
	for i in settings_items.size():
		if settings_items[i]["text"] == "":
			var spacer = Control.new()
			spacer.custom_minimum_size.y = 20
			settings_container.add_child(spacer)
			continue
		
		var btn = Button.new()
		btn.text = settings_items[i]["text"]
		btn.custom_minimum_size = Vector2(400, 50)
		btn.add_theme_font_size_override("font_size", 24)
		btn.pressed.connect(_on_settings_button_selected.bind(settings_items[i]["action"]))
		settings_container.add_child(btn)

func _update_credits_display() -> void:
	var credits_text = """
═══════════════════════════════════════════════════════

                    UNDERTALE: DARK UNDERGROUND
                         - CRÉDITOS -

═══════════════════════════════════════════════════════


                    "Even in darkness, there is always hope."


─────────────────────────────────────────────────────────

                    INSPIRADO POR

─────────────────────────────────────────────────────────

              • UNDERTALE - Toby Fox
              • DELTARUNE - Toby Fox

             Gracias por crear mundos tan increíbles
              que nos inspiran a crear los nuestros.


─────────────────────────────────────────────────────────

                    DESARROLLO

─────────────────────────────────────────────────────────

              • Programación & Diseño
              • Historia Original
              • Arte de Personajes
              • Ambientes & Escenarios
              • Diseño de Batallas


─────────────────────────────────────────────────────────

                    AGRADECIMIENTOS

─────────────────────────────────────────────────────────

              • Toby Fox - Por Undertale y Deltarune
              • La comunidad de fans
              • Todos los creadores de fangames
              • Los artistas de pixel art
              • Los músicos que inspiran


─────────────────────────────────────────────────────────

                    INFORMACIÓN LEGAL

─────────────────────────────────────────────────────────

              Este es un FAN GAME no comercial.

              Creado con fines educativos y de entretenimiento.
              NO contiene publicidad, NO acepta donaciones,
              NO tiene intención de lucro.

              Undertale y Deltarune son propiedad intelectual
              de Toby Fox / The Indie Crowd.

              Este proyecto NO está afiliado oficialmente
              con Toby Fox ni con Game Maker.


─────────────────────────────────────────────────────────

                    LICENCIA

─────────────────────────────────────────────────────────

              • Código: MIT License
              • Arte Original: CC0 (Dominio Público)
              • Undertale/Deltarune IP: © Toby Fox

              Eres libre de estudiar y modificar este código
              para uso personal y educativo.


═══════════════════════════════════════════════════════


              Gracias por jugar. 💜


═══════════════════════════════════════════════════════


                    Presiona ENTER para volver


"""
	credits_label.text = credits_text

func _update_chapter_display() -> void:
	for child in chapter_container.get_children():
		child.queue_free()
	
	# Header
	var header = Label.new()
	header.text = "- SELECCIONAR CAPÍTULO -"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 32)
	chapter_container.add_child(header)
	
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 30
	chapter_container.add_child(spacer)
	
	# Chapter buttons
	var chapters = [
		{"name": "CAPÍTULO 1", "desc": "El Despertar Oscuro", "status": "✓ JUGABLE"},
		{"name": "CAPÍTULO 2", "desc": "La Arista de las Sombras", "status": "🔒 BLOQUEADO"},
		{"name": "CAPÍTULO 3", "desc": "El Caos Reina", "status": "🔒 BLOQUEADO"},
	]
	
	for i in chapters.size():
		var btn = Button.new()
		btn.text = "%s\n%s - %s" % [chapters[i]["name"], chapters[i]["status"], chapters[i]["desc"]]
		btn.custom_minimum_size = Vector2(450, 90)
		btn.add_theme_font_size_override("font_size", 22)
		if i == 0:
			btn.pressed.connect(_start_game)
		else:
			btn.pressed.connect(_show_locked_message)
		chapter_container.add_child(btn)
	
	spacer = Control.new()
	spacer.custom_minimum_size.y = 20
	chapter_container.add_child(spacer)
	
	# Extra modes
	var extras_btn = Button.new()
	extras_btn.text = "MODO BOSS RUSH 🔒"
	extras_btn.custom_minimum_size = Vector2(450, 70)
	extras_btn.add_theme_font_size_override("font_size", 20)
	chapter_container.add_child(extras_btn)
	
	var extras_btn2 = Button.new()
	extras_btn2.text = "GALERÍA 🔒"
	extras_btn2.custom_minimum_size = Vector2(450, 70)
	extras_btn2.add_theme_font_size_override("font_size", 20)
	chapter_container.add_child(extras_btn2)
	
	spacer = Control.new()
	spacer.custom_minimum_size.y = 30
	chapter_container.add_child(spacer)
	
	# Back button
	var back_btn = Button.new()
	back_btn.text = "> VOLVER AL MENÚ"
	back_btn.custom_minimum_size = Vector2(250, 50)
	back_btn.pressed.connect(_show_main_menu)
	chapter_container.add_child(back_btn)

func _on_main_button_selected(action: String) -> void:
	match action:
		"_start_game": _show_chapter_select()
		"_show_settings": _show_settings()
		"_show_credits": _show_credits()
		"_quit_game": _quit_game()

func _on_settings_button_selected(action: String) -> void:
	match action:
		"vol_master":
			master_volume = wrapf(master_volume - 0.1, 0.0, 1.01)
			_update_settings_display()
			_save_settings()
		"vol_music":
			music_volume = wrapf(music_volume - 0.1, 0.0, 1.01)
			_update_settings_display()
			_save_settings()
		"vol_sfx":
			sfx_volume = wrapf(sfx_volume - 0.1, 0.0, 1.01)
			_update_settings_display()
			_save_settings()
		"toggle_fullscreen":
			fullscreen = !fullscreen
			_apply_fullscreen()
			_update_settings_display()
			_save_settings()
		"text_speed":
			text_speed = wrapf(text_speed + 0.5, 0.5, 3.1)
			_update_settings_display()
			_save_settings()
		"battle_speed":
			battle_speed = wrapf(battle_speed + 0.5, 0.5, 3.1)
			_update_settings_display()
			_save_settings()
		"_show_main_menu":
			_show_main_menu()

func _apply_fullscreen() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _start_game() -> void:
	fade_rect.visible = true
	fade_rect.color.a = 0
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)
	await tween.finished
	
	SaveSystem.delete_save(0)
	GlobalVariables.reset_all_progress()
	GlobalVariables.current_chapter = 1
	
	get_tree().change_scene_to_file("res://scenes/levels/CompleteLevel.tscn")

func _show_locked_message() -> void:
	var popup = AcceptDialog.new()
	popup.dialog_text = "¡Este contenido aún no está disponible!\nCompleta el Capítulo 1 primero."
	popup.ok_button_text = "OK"
	add_child(popup)
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)

func _quit_game() -> void:
	fade_rect.visible = true
	fade_rect.color.a = 0
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)
	await tween.finished
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match current_state:
			MenuState.SETTINGS, MenuState.CREDITS, MenuState.CHAPTER_SELECT:
				_show_main_menu()
			MenuState.MAIN:
				_quit_game()
	elif event.is_action_pressed("ui_accept"):
		match current_state:
			MenuState.CREDITS:
				_show_main_menu()
