extends Node2D

# DarkWorldEntry.gd
# Deltarune-style Chapter 1: Frisk enters Dark World accidentally
# Characters: Kris, Susie, Ralsei-style character enters with Frisk
# No voice - text only

@onready var text_box: Control = $TextBox
@onready var player: CharacterBody2D = $Player
@onready var dark_fountain: Node2D = $DarkFountain
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var screen_effect: ColorRect = $ScreenEffect

# State machine
enum State {
	INTRO,
	EXPLORING,
	DARK_FOUNTAIN_APPEARS,
	ENTERING_DARK,
	DARK_WORLD_INTRO,
	DARK_WORLD_GAMEPLAY,
	CHAPTER_END
}

var current_state: State = State.INTRO
var dialogue_index: int = 0
var can_advance: bool = false
var is_in_dialogue: bool = true

# Dark World characters (instead of Lancer/Ralsei)
# Using Kris and Susie-style characters from our roster
var dark_party: Array = []

# Complete Deltarune-style dialogue
var intro_sequence: Array = [
	# Scene 1: Light World - Ruins-like area
	{"text": "* Te encuentras caminando por el pasillo de piedra...", "narration": true},
	{"text": "* Es un lugar antiguo, con antorchas que parpadean.", "narration": true},
	{"text": "* El aire se siente... diferente hoy.", "narration": true},
	
	# Scene 2: Met Kris
	{"speaker": "???", "name_color": Color(0.8, 0.5, 0.2), "text": "Oye.", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "...", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "Tú eres nuevo aquí, ¿verdad?", "narration": false},
	{"speaker": "???", "text": "..."},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "Soy Kris. No te acerques mucho a...", "narration": false},
	
	# Scene 3: Met Susie
	{"speaker": "SUSIE", "name_color": Color(0.6, 0.3, 0.3), "text": "¡HEY!", "narration": false},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "¿Qué están haciendo ustedes dos aquí?", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "Susie. Mira eso.", "narration": false},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "¿Qué? ¿Esa fuente rara?", "narration": false},
	
	# Scene 4: Dark Fountain appears
	{"text": "* Una fuente de oscuridad emerge del suelo...", "narration": true},
	{"text": "* La habitación tiembla.", "narration": true},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "¿¡QUÉ DIABLOS ES ESO!?", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "Una Dark Fountain...", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "¡Hay que cerrar eso!", "narration": false},
	
	# Scene 5: Frisk gets pulled in
	{"text": "* La oscuridad te atrae hacia la fuente...", "narration": true},
	{"text": "* No puedes resistirte.", "narration": true},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "¡HEY! ¡El humano está siendo arrastrado!", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "¡Tengo que ir tras él!", "narration": false},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "Ugh... yo también voy.", "narration": false},
	
	# Scene 6: Fall into Dark World
	{"text": "* Caen al interior de la fuente...", "narration": true},
	{"text": "* Todo se vuelve negro.", "narration": true},
	{"text": "* El tiempo se detiene.", "narration": true},
	
	# Scene 7: Dark World awakening
	{"text": "* ...", "narration": true},
	{"text": "* Despiertas en un lugar completamente diferente.", "narration": true},
	{"text": "* Todo está hecho de piedra oscura y cielo púrpura.", "narration": true},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "¿Dónde... dónde estamos?", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "Un Dark World.", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "Pero esto es diferente a lo que conocía.", "narration": false},
	
	# Scene 8: Meet Ralsei (our character)
	{"speaker": "RALSEI", "name_color": Color(0.4, 0.7, 0.4), "text": "... Oh!", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "¡Visitantes! ¡Desde el mundo de luz!", "narration": false},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "¿¡Quién eres tú!?", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "Soy Ralsei. El príncipe de este reino.", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "Y ustedes... ustedes pueden cerrar las Dark Fountains.", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "¿Cómo lo sabes?", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "Porque... es mi destino saberlo.", "narration": false},
	
	# Scene 9: Form the party
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "Esto es ridículo. ¿Un príncipe fluffy?", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "...Lo sé. No parezco amenazante.", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "Pero puedo ayudar con magia de luz.", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "Necesitamos volver al mundo de luz.", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "Para eso, debemos cerrar las Dark Fountains.", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "Esta fuente... la nuestra... debemos sellarla.", "narration": false},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "Ugh. ¿Tenemos que hacer más trabajo?", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "Juntos, podemos hacerlo.", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "¿Quieren ser... mis amigos?", "narration": false},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "...¿Qué?", "narration": false},
	{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "...", "narration": false},
	{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "Quiero decir... un equipo. Quiero decir, equipo.", "narration": false},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "Pfft. Está bien, está bien.", "narration": false},
	{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "Pero no me llames amiga.", "narration": false},
	
	# Scene 10: Chapter title
	{"text": "", "is_title": true, "title_text": "DARK UNDERGROUND"},
	{"text": "", "is_subtitle": true, "title_text": "Capítulo 1: La Fuente de Luz"},
	
	# Scene 11: Gameplay starts
	{"text": "* Eligen sus armas y se preparan.", "narration": true},
	{"text": "* Pulsan Z para continuar.", "narration": true},
]

var current_line: Dictionary = {}

func _ready() -> void:
	fade_overlay.color = Color.BLACK
	screen_effect.visible = false
	
	# Start intro
	_start_intro()

func _start_intro() -> void:
	current_state = State.INTRO
	is_in_dialogue = true
	dark_party = ["frisk", "kris", "susie", "ralsei"]
	
	# Fade in
	fade_overlay.visible = true
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 2.0)
	tween.finished.connect(_on_fade_in_complete)

func _on_fade_in_complete() -> void:
	fade_overlay.visible = false
	_show_line(0)

func _show_line(index: int) -> void:
	if index >= intro_sequence.size():
		_start_gameplay()
		return
	
	dialogue_index = index
	current_line = intro_sequence[index]
	can_advance = true
	
	# Handle special line types
	if current_line.get("is_title", false):
		_show_title()
		return
	
	if current_line.get("is_subtitle", false):
		_show_subtitle()
		return
	
	# Update text box
	text_box.show_text(
		current_line.get("text", ""),
		current_line.get("speaker", ""),
		current_line.get("narration", false)
	)

func _show_title() -> void:
	screen_effect.visible = true
	screen_effect.color = Color.BLACK
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.finished.connect(_next_line)

func _show_subtitle() -> void:
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.finished.connect(_next_line)

func _next_line() -> void:
	_show_line(dialogue_index + 1)

func _process(_delta: float) -> void:
	if is_in_dialogue and can_advance:
		if Input.is_action_just_pressed("ui_accept"):
			can_advance = false
			_advance_dialogue()

func _advance_dialogue() -> void:
	if current_line.get("is_title", false) or current_line.get("is_subtitle", false):
		return
	
	# Check if typewriter is still running
	if text_box.is_typing:
		text_box.skip_typing()
	else:
		_next_line()

func _start_gameplay() -> void:
	current_state = State.DARK_WORLD_GAMEPLAY
	is_in_dialogue = false
	
	# Hide text box
	text_box.hide()
	
	# Enable player movement
	player.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Show gameplay instructions
	_show_controls_hint()

func _show_controls() -> void:
	is_in_dialogue = true
	var controls_text = [
		{"text": "* Controles:", "narration": true},
		{"text": "* Flechas: Moverte", "narration": true},
		{"text": "* Z: Continuar / Hablar", "narration": true},
		{"text": "* X: Menú", "narration": true},
		{"text": "* Encuentra a los enemigos y cierra la Dark Fountain.", "narration": true},
	]
	
	# Show one by one
	pass

func _show_controls_hint() -> void:
	# Show brief control reminder
	var hint = Label.new()
	hint.text = "← → ↑ ↓ Mover  |  Z Continuar  |  X Menú"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, 680)
	hint.size = Vector2(1280, 40)
	hint.add_theme_font_size_override("font_size", 16)
	hint.modulate = Color(0.7, 0.7, 0.7, 0.8)
	add_child(hint)
	
	# Fade out hint
	await get_tree().create_timer(5.0).timeout
	var fade_hint = create_tween()
	fade_hint.tween_property(hint, "modulate:a", 0.0, 1.0)
	fade_hint.finished.connect(hint.queue_free)

func get_party() -> Array:
	return dark_party

func complete_chapter() -> void:
	current_state = State.CHAPTER_END
	_trigger_ending()

func _trigger_ending() -> void:
	is_in_dialogue = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Show ending
	var ending_lines = [
		{"text": "* La Dark Fountain se cierra con un último destello de luz.", "narration": true},
		{"text": "* El Dark World comienza a desvanecerse.", "narration": true},
		{"speaker": "Ralsei", "name_color": Color(0.4, 0.7, 0.4), "text": "Lo lograron.", "narration": false},
		{"speaker": "Susie", "name_color": Color(0.6, 0.3, 0.3), "text": "Eso fue... increíble.", "narration": false},
		{"speaker": "Kris", "name_color": Color(0.8, 0.5, 0.2), "text": "Pero esto es solo el comienzo.", "narration": false},
		{"text": "* Son transportados de vuelta al mundo de luz.", "narration": true},
		{"text": "* Todo parece normal... por ahora.", "narration": true},
		{"text": "* Pero algo se avecina en el horizonte.", "narration": true},
		{"text": "", "is_title": true, "title_text": "FIN DEL CAPÍTULO 1"},
	]
	
	_show_line(0)

func get_current_state() -> State:
	return current_state
