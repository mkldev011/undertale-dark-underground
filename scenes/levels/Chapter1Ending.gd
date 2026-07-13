extends Node2D

# Chapter1Ending.gd
# Chapter 1 Ending - Frisk's Dark Transformation

@onready var frisk_bed: Sprite2D = $BedArea/Frisk
@onready var dialogue_box: Control = $DialogueBox
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var dark_effect: ColorRect = $DarkEffect
@onready var text_label: Label = $DialogueBox/TextLabel
@onready var narration: Label = $NarrationLabel

var dialogue_index: int = 0
var is_animating: bool = false
var dark_level: float = 0.0  # 0 = normal, 1 = fully corrupted
var eye_color_changed: bool = false

var ending_dialogue: Array = [
	{
		"speaker": "",
		"text": "* Terminaste tu primera aventura en el Underground.",
		"narration": "La luz de la mañana se filtra por la ventana..."
	},
	{
		"speaker": "Toriel",
		"text": "Buenos días, mi hijo. ¿Descansaste bien?",
		"narration": "Toriel te mira con cariño desde la puerta."
	},
	{
		"speaker": "",
		"text": "* Asientes, pero algo se siente... diferente.",
		"narration": "Los recuerdos de la batalla contra el Guardián aún están frescos."
	},
	{
		"speaker": "Toriel",
		"text": "El desayuno está listo. Hice huevos y... bueno, ya sabes.",
		"narration": "Sonríe, pero notas preocupación en sus ojos."
	},
	{
		"speaker": "",
		"text": "* Te quedas en la cama un momento más.",
		"narration": "Las sombras bajo tus párpados se mueven de forma extraña."
	},
	{
		"speaker": "",
		"text": "* En tu mente, escuchas un susurro...",
		"narration": "\"Eso fue solo el comienzo.\""
	},
	{
		"speaker": "???",
		"text": "¿Escuchaste eso?",
		"narration": "Una voz que conoces... pero no recuerdas de dónde."
	},
	{
		"speaker": "",
		"text": "* Tu corazón late con fuerza.",
		"narration": "Algo dentro de ti ha despertado."
	},
	{
		"speaker": "???",
		"text": "Somos uno ahora. Tú y yo.",
		"narration": "La voz es suave, casi amigable... casi."
	},
	{
		"speaker": "",
		"text": "* Te levantas de la cama y miras tus manos.",
		"narration": "Por un instante... parpadean en rojo."
	},
	{
		"speaker": "",
		"text": "* \"¿Qué está pasando conmigo?\"",
		"narration": "El pensamiento cruza tu mente sin que lo invoques."
	},
	{
		"speaker": "???",
		"text": "Nada está mal. Todo está... como debería ser.",
		"narration": "Esa sonrisa. Esa sonrisa que has visto antes."
	},
	{
		"speaker": "",
		"text": "* Un escalofrío recorre tu espalda.",
		"narration": "Te preguntas qué habrías hecho si...",
	},
	{
		"speaker": "",
		"text": "* ...si hubieras matado a todos.",
		"narration": "La idea no te asusta como debería."
	},
	{
		"speaker": "???",
		"text": "Mmm. Interesante.",
		"narration": "Una risa suave, como campanas.",
	},
	{
		"speaker": "",
		"text": "* El espejo en la habitación muestra algo extraño.",
		"narration": "Tu reflejo... no sonríe igual que tú."
	},
	{
		"speaker": "???",
		"text": "Nos vemos pronto, Frisk.",
		"narration": "La voz se desvanece.",
	},
	{
		"speaker": "???",
		"text": "Muy pronto...",
		"narration": "Te preguntas si realmente la escuchaste."
	},
	{
		"speaker": "",
		"text": "* Sacudes la cabeza y sonríes.",
		"narration": "Solo fue un sueño extraño."
	},
	{
		"speaker": "Toriel",
		"text": "¿Vienes, mi hijo? La comida se enfría.",
		"narration": "Todo parece normal."
	},
	{
		"speaker": "",
		"text": "* Pero cuando sales de la habitación...",
		"narration": "...tus ojos brillan rojo por un instante.",
	},
	{
		"speaker": "",
		"text": "* Nadie lo nota.",
		"narration": "Pero tú sí."
	},
	{
		"speaker": "",
		"text": "* Nadie lo nota... todavía.",
		"narration": "FIN DEL CAPÍTULO 1"
	}
]

func _ready() -> void:
	fade_overlay.color = Color.BLACK
	dark_effect.color = Color(1, 0, 0, 0)  # Transparent red overlay
	dark_effect.visible = false
	_start_ending()

func _start_ending() -> void:
	is_animating = true
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 2.0)
	await tween.finished
	
	fade_overlay.visible = false
	
	# Start dialogue
	_show_dialogue(0)

func _show_dialogue(index: int) -> void:
	if index >= ending_dialogue.size():
		_show_final_screen()
		return
	
	dialogue_index = index
	var line = ending_dialogue[index]
	
	# Update narration
	if line.has("narration"):
		_show_narration(line["narration"])
	
	# Show text with typewriter effect
	var full_text = ""
	if line["speaker"] != "":
		full_text = line["speaker"] + ": " + line["text"]
	else:
		full_text = line["text"]
	
	_type_text(full_text)

func _show_narration(text: String) -> void:
	narration.text = text
	narration.visible = true
	
	var tween = create_tween()
	tween.tween_interval(0.5)
	await tween.finished

func _type_text(text: String) -> void:
	text_label.text = ""
	
	var tween = create_tween()
	for i in range(text.length()):
		text_label.text = text.substr(0, i + 1)
		await get_tree().create_timer(0.03).timeout
	
	# Apply dark effect based on dialogue progress
	_update_dark_effect()

func _update_dark_effect() -> void:
	# Increase dark level as dialogue progresses
	dark_level = float(dialogue_index) / float(ending_dialogue.size())
	
	# Show dark effect at certain points
	if dialogue_index >= 10:
		dark_effect.visible = true
		dark_effect.color.a = dark_level * 0.3
		
		# Animate Frisk's eyes
		if dialogue_index == 15 and not eye_color_changed:
			eye_color_changed = true
			_animate_eye_change()

func _animate_eye_change() -> void:
	# Flash red
	var flash = create_tween()
	flash.tween_property(frisk_bed, "modulate", Color(2, 0, 0, 1), 0.1)
	flash.tween_property(frisk_bed, "modulate", Color(1, 1, 1, 1), 0.1)
	flash.tween_property(frisk_bed, "modulate", Color(2, 0, 0, 1), 0.1)
	flash.tween_property(frisk_bed, "modulate", Color(1, 1, 1, 1), 0.3)
	await flash.finished
	
	# Darken Frisk slightly
	frisk_bed.modulate = Color(0.9, 0.9, 1.0, 1.0)

func _process(_delta: float) -> void:
	if is_animating:
		return
	
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_down"):
		if text_label.text.length() < ending_dialogue[dialogue_index]["text"].length():
			# Skip typewriter
			if ending_dialogue[dialogue_index]["speaker"] != "":
				text_label.text = ending_dialogue[dialogue_index]["speaker"] + ": " + ending_dialogue[dialogue_index]["text"]
			else:
				text_label.text = ending_dialogue[dialogue_index]["text"]
		else:
			_show_dialogue(dialogue_index + 1)

func _show_final_screen() -> void:
	is_animating = true
	
	# Final fade to black with stronger dark effect
	fade_overlay.visible = true
	dark_effect.visible = true
	
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0.02, 0.02, 0.05, 1), 3.0)
	tween.parallel().tween_property(dark_effect, "color:a", 0.5, 3.0)
	
	await tween.finished
	
	_show_chapter_complete()

func _show_chapter_complete() -> void:
	narration.visible = false
	text_label.visible = false
	
	# Show chapter complete text
	var complete_label = Label.new()
	complete_label.text = "CAPÍTULO 1 COMPLETADO"
	complete_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	complete_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	complete_label.add_theme_font_size_override("font_size", 48)
	complete_label.modulate = Color(0.9, 0.3, 0.3, 1)
	complete_label.set_position(Vector2(0, 300))
	complete_label.set_size(Vector2(1280, 100))
	add_child(complete_label)
	
	# Fade in title
	var title_tween = create_tween()
	title_tween.tween_property(complete_label, "modulate:a", 1.0, 2.0)
	await title_tween.finished
	
	# Show teaser
	var teaser_label = Label.new()
	teaser_label.text = "Capítulo 2: La Arista de las Sombras"
	teaser_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	teaser_label.add_theme_font_size_override("font_size", 24)
	teaser_label.modulate = Color(0.5, 0.3, 0.8, 1)
	teaser_label.set_position(Vector2(0, 400))
	teaser_label.set_size(Vector2(1280, 50))
	teaser_label.modulate.a = 0
	add_child(teaser_label)
	
	var teaser_tween = create_tween()
	teaser_tween.tween_property(teaser_label, "modulate:a", 1.0, 2.0)
	await teaser_tween.finished
	
	# Wait then fade out
	await get_tree().create_timer(3.0).timeout
	
	var fade_out = create_tween()
	fade_out.tween_property(complete_label, "modulate:a", 0.0, 1.0)
	fade_out.parallel().tween_property(teaser_label, "modulate:a", 0.0, 1.0)
	await fade_out.finished
	
	# Save progress and return to menu
	GlobalVariables.set_flag("chapter1_complete")
	GlobalVariables.set_flag("frisk_darkness_level", dark_level)
	
	get_tree().change_scene_to_file("res://scenes/core/MainMenu.tscn")
