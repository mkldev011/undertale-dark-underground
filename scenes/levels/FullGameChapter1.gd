extends Node2D

# FullGameChapter1.gd
# Complete Chapter 1: Undertale style until Toriel's house, then Dark Fountain appears
# Flow: Undertale exploration → Toriel's House → Dark Fountain → Dark World → Return

# Game phases
enum Phase {
	UNDERTALE_EXPLORATION,
	TORIEL_HOUSE_INTRO,
	DARK_FOUNTAIN_APPEARS,
	FALL_INTO_DARK,
	DARK_WORLD,
	CHAPTER_END
}

var current_phase: Phase = Phase.UNDERTALE_EXPLORATION
var dialogue_index: int = 0
var can_advance: bool = false
var is_in_dialogue: bool = true
var fountains_sealed: int = 0

# References
@onready var player: CharacterBody2D = $Player
@onready var toriel: Node2D = $Toriel
@onready var dark_fountain: Node2D = $DarkFountain
@onready var text_box: Control = $TextBox
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var ruin_areas: Node2D = $RuinAreas
@onready var toriel_house: Node2D = $TorielHouse

# Undertale-style dialogue for exploration
var exploration_dialogue: Array = [
	{"text": "* Estás caminando por las Ruinas.", "narration": true},
	{"text": "* Es un lugar antiguo, con antorchas que parpadean.", "narration": true},
	{"text": "* Puertas de piedra bloquean el camino a veces.", "narration": true},
	{"text": "* Hay hojas caídas por todos lados.", "narration": true},
]

var toriel_house_dialogue: Array = [
	{"speaker": "Toriel", "text": "¡Oh! Has llegado a salvo, mi hijo."},
	{"speaker": "Toriel", "text": "Bienvenido a mi hogar."},
	{"speaker": "Toriel", "text": "¿Tienes hambre? Puedo prepararte algo."},
	{"text": "* Te sientas en el sofá.", "narration": true},
	{"speaker": "Toriel", "text": "Descansa un momento. Te prepararé la habitación."},
	{"text": "* De pronto, el suelo tiembla...", "narration": true},
	{"text": "* Algo oscuro emerge del centro de la habitación.", "narration": true},
]

var dark_fountain_dialogue: Array = [
	{"speaker": "???", "text": "..."},
	{"speaker": "???", "text": "Al fin..."},
	{"speaker": "???", "text": "Una luz en la oscuridad."},
	{"speaker": "Toriel", "text": "¿¡Qué es eso!?"},
	{"speaker": "Toriel", "text": "¡Una Dark Fountain! ¡Hay que cerrar eso!"},
	{"text": "* La fuente de oscuridad crece rápidamente...", "narration": true},
	{"text": "* Te arrastra hacia su interior.", "narration": true},
	{"speaker": "Toriel", "text": "¡NO!"},
	{"speaker": "???", "text": "Ven."},
	{"text": "* Todo se vuelve negro.", "narration": true},
]

var dark_world_dialogue: Array = [
	{"text": "* Despiertas en un lugar completamente diferente.", "narration": true},
	{"text": "* Todo está hecho de piedra oscura y cielo púrpura.", "narration": true},
	{"speaker": "Kris", "text": "..."},
	{"speaker": "Susie", "text": "Ugh... ¿dónde estamos?"},
	{"speaker": "Kris", "text": "Un Dark World."},
	{"speaker": "Kris", "text": "Esta fountain... hay que cerrarla."},
	{"speaker": "Ralsei", "text": "..."},
	{"speaker": "Ralsei", "text": "¡Oh! ¡Visitantes!"},
	{"speaker": "Susie", "text": "¿¡Quién eres tú!?"},
	{"speaker": "Ralsei", "text": "Soy Ralsei. El príncipe de este reino oscuro."},
	{"speaker": "Ralsei", "text": "Juntos podemos cerrar la Dark Fountain."},
	{"speaker": "Susie", "text": "Ugh... está bien, está bien."},
	{"speaker": "Ralsei", "text": "¿Quieren... ser mis amigos?"},
	{"speaker": "Susie", "text": "¿¡QUÉ!?"},
	{"text": "", "is_title": true},
	{"text": "CAPÍTULO 1", "subtitle": true},
	{"text": "La Fuente de Luz", "subtitle": true},
	{"text": "* Se preparan para la batalla.", "narration": true},
]

var current_dialogue: Array = []
var current_line: Dictionary = {}

func _ready() -> void:
	# Setup initial state
	toriel_house.visible = false
	dark_fountain.visible = false
	
	# Start Undertale-style intro
	fade_overlay.color = Color.BLACK
	_start_intro()

func _start_intro() -> void:
	# Fade in
	fade_overlay.visible = true
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 1.5)
	await tween.finished
	fade_overlay.visible = false
	
	current_phase = Phase.UNDERTALE_EXPLORATION
	current_dialogue = exploration_dialogue
	_show_line(0)

func _show_line(index: int) -> void:
	if index >= current_dialogue.size():
		_on_dialogue_complete()
		return
	
	dialogue_index = index
	current_line = current_dialogue[index]
	can_advance = true
	
	# Handle title
	if current_line.get("is_title", false):
		_show_chapter_title()
		return
	
	# Show text
	text_box.show_text(
		current_line.get("text", ""),
		current_line.get("speaker", ""),
		current_line.get("narration", false)
	)

func _show_chapter_title() -> void:
	fade_overlay.visible = true
	fade_overlay.color = Color(0.02, 0.02, 0.05, 1)
	
	var title = Label.new()
	title.text = "CAPÍTULO 1"
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.set_position(Vector2(0, 300))
	title.set_size(Vector2(1280, 100))
	add_child(title)
	
	await get_tree().create_timer(2.0).timeout
	
	var fade_out = create_tween()
	fade_out.tween_property(fade_overlay, "color:a", 0.0, 1.0)
	title.queue_free()
	await fade_out.finished
	fade_overlay.visible = false
	
	_on_dialogue_complete()

func _on_dialogue_complete() -> void:
	match current_phase:
		Phase.UNDERTALE_EXPLORATION:
			_start_toriel_house()
		Phase.TORIEL_HOUSE_INTRO:
			_trigger_dark_fountain()
		Phase.DARK_FOUNTAIN_APPEARS:
			_fall_into_dark()
		Phase.FALL_INTO_DARK:
			_start_dark_world()
		Phase.DARK_WORLD:
			_complete_chapter()

func _start_toriel_house() -> void:
	current_phase = Phase.TORIEL_HOUSE_INTRO
	current_dialogue = toriel_house_dialogue
	
	# Show Toriel's house
	ruin_areas.visible = false
	toriel_house.visible = true
	toriel.visible = true
	
	# Position player in house
	player.position = Vector2(640, 500)
	
	_show_line(0)

func _trigger_dark_fountain() -> void:
	current_phase = Phase.DARK_FOUNTAIN_APPEARS
	current_dialogue = dark_fountain_dialogue
	
	# Show dark fountain
	dark_fountain.visible = true
	dark_fountain.scale = Vector2.ZERO
	
	# Animate fountain appearing
	var tween = create_tween()
	tween.tween_property(dark_fountain, "scale", Vector2.ONE, 2.0)
	tween.parallel().tween_property(dark_fountain, "rotation", TAU, 2.0)
	await tween.finished
	
	_show_line(0)

func _fall_into_dark() -> void:
	current_phase = Phase.FALL_INTO_DARK
	
	# Animate player being pulled in
	var tween = create_tween()
	tween.tween_property(player, "position", dark_fountain.position, 1.5)
	tween.parallel().tween_property(player, "scale", Vector2.ZERO, 1.5)
	await tween.finished
	
	# Fade to black
	var fade = create_tween()
	fade.tween_property(fade_overlay, "color:a", 1.0, 1.0)
	await fade.finished
	
	_show_line(0)

func _start_dark_world() -> void:
	current_phase = Phase.DARK_WORLD
	current_dialogue = dark_world_dialogue
	
	# Reset player for dark world
	player.position = Vector2(640, 500)
	player.scale = Vector2.ONE
	
	# Change background to dark world
	toriel_house.visible = false
	fade_overlay.color = Color(0.1, 0.05, 0.15, 1)
	
	# Fade in
	fade_overlay.visible = true
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 1.0)
	await tween.finished
	fade_overlay.visible = false
	
	_show_line(0)

func _complete_chapter() -> void:
	current_phase = Phase.CHAPTER_END
	
	# Fade out
	fade_overlay.visible = true
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 2.0)
	await tween.finished
	
	# Show chapter complete
	var complete = Label.new()
	complete.text = "CAPÍTULO 1 COMPLETADO"
	complete.add_theme_font_size_override("font_size", 48)
	complete.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	complete.set_position(Vector2(0, 350))
	complete.set_size(Vector2(1280, 100))
	add_child(complete)
	
	await get_tree().create_timer(2.0).timeout
	
	# Return to menu
	get_tree().change_scene_to_file("res://scenes/core/MainMenu.tscn")

func _process(_delta: float) -> void:
	if is_in_dialogue and can_advance:
		if Input.is_action_just_pressed("ui_accept"):
			can_advance = false
			_advance_dialogue()

func _advance_dialogue() -> void:
	if current_line.get("is_title", false):
		return
	
	if text_box.is_complete:
		_show_line(dialogue_index + 1)

func _input(event: InputEvent) -> void:
	# Allow movement during non-dialogue phases
	if current_phase == Phase.UNDERTALE_EXPLORATION and not is_in_dialogue:
		_handle_player_movement()

func _handle_player_movement() -> void:
	var velocity = Vector2.ZERO
	velocity.x = Input.get_axis("ui_left", "ui_right")
	velocity.y = Input.get_axis("ui_up", "ui_down")
	
	player.velocity = velocity * 200
	player.move_and_slide()

# Called when player reaches Toriel's house
func _on_reached_toriel_house() -> void:
	if current_phase == Phase.UNDERTALE_EXPLORATION:
		is_in_dialogue = true
		player.process_mode = Node.PROCESS_MODE_DISABLED
