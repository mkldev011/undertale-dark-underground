extends Node

# RandomEvents.gd
# Random events, tips, and easter eggs for the game

var tips = [
	"💡 Los fantasmas pueden ser derrotados con bondad...",
	"💡 ¿Sabías que Sans ha estado observando?",
	"💡 Papyrus hace la mejor pasta... según él.",
	"💡 Toriel solía hornear caramelos de冰.",
	"💡 Alphys ve mucho anime en su tiempo libre.",
	"💡 Undyne puede lanzar 50 lanzas por segundo.",
	"💡 Mettaton tiene más de 10000 seguidores.",
	"💡 Flowey siempre está sonriendo...",
	"💡 Los ecos de Waterfall guardan secretos.",
	"💡 Los fountains oscuros son peligrosos.",
	"💡 La determinación es clave.",
	"💡 Puedes ahorrar TP usando MAGIA.",
	"💡 Algunos monstruos no quieren luchar.",
	"💡 La bondad puede salvar mundos.",
	"💡 ¡Hay un secreto en la habitación de Sans!",
	"💡 No confíes en nadie... especialmente en flores.",
	"💡 El烹饪 es importante para la supervivencia.",
	"💡 Las flores de eco susurran verdades.",
	"💡 Kris tiene secretos que no conoce.",
	"💡 Ralsei es más fuerte de lo que parece.",
	"💡 Susie golpea cosas cuando está triste.",
	"💡 Noelle tiene poderes latentes...",
	"💡 Berdly usa gafas para parecer inteligente.",
	"💡 Lancer es más listo de lo que parece.",
	"💡 La Reina quiere ser temida... y amada.",
]

var easter_eggs = [
	"debug_secret_unlocked",
	"flowey_laugh_13_times",
	"sans_secret_room",
	"hidden_fountain",
	"true_ending_triggered",
	"shadow_king_revealed",
]

var fun_dialogues = [
	{
		"character": "???",
		"text": "¿Estás jugando con fuego?" },
	{
		"character": "???",
		"text": "O con oscuridad..." },
	{
		"character": "???",
		"text": "Eso es aún peor. 😈" },
]

var random_jokes = [
	"¿Por qué los esqueletos no fighteen?\n¡Porque no tienen agallas! 💀",
	"¿Qué dice un monstruo cuando está confundido?\nNo tengo NI IDEA 🦴",
	"¿Cómo llamas a un dinosaurio que miente?\n¡Un FOSSIL! 🦕",
	"¿Qué hace un monstruo en el gym?\n¡Entrenamiento MONSTRUOSO! 💪",
	"¿Por qué el fantasma no ganó la batalla?\n¡Le faltó GANAS! 👻",
	"¿Qué pasa si comes un reloj?\n¡Te comes el TIEMPO! ⏰",
	"¿Cómo saludan los robots?\n¡Con circuitos! 🤖",
]

var fun_facts = {
	"toriel": [
		"Toriel ha bakeado más de 10000 galletas.",
		"Sabe 47 recetas diferentes de caramelos.",
		"Fuerza: ¡Puede cargar un sofá con una mano!",
		"Su hobby secreto: crossword puzzles.",
	],
	"sans": [
		"sans ha juzgado a 0 humanos (por ahora).",
		"Su sonrisa tiene 3 watios de poder.",
		"Sabe 200 chistes malos.",
		"Papyrus le ha ganado 0 veces en cocinar.",
	],
	"papyrus": [
		"Ha capturado 0 humanos (todavía).",
		"Su cocina ha mejorado MUCHO.",
		"Conoce a todos los NPC de Snowdin.",
		"Su armor es 100% de moda.",
	],
	"flowey": [
		"Siempre está smiling... demasiado.",
		"Conoce todos los resets.",
		"Su sonrisa nunca reaches sus ojos.",
		"¿Recuerdas...? No importa.",
	]
}

func get_random_tip() -> String:
	return tips[randi() % tips.size()]

func get_random_joke() -> String:
	return fun_jokes[randi() % fun_jokes.size()]

func get_character_fun_fact(character: String) -> String:
	if fun_facts.has(character):
		var facts = fun_facts[character]
		return facts[randi() % facts.size()]
	return ""

func trigger_random_event() -> Dictionary:
	var events = [
		{
			"type": "tip",
			"text": get_random_tip(),
			"chance": 0.3
		},
		{
			"type": "joke",
			"text": get_random_joke(),
			"chance": 0.2
		},
		{
			"type": "easter_egg",
			"text": "🎮 ¡Easter egg encontrado!",
			"chance": 0.05
		},
	]
	
	# Weight by chance
	var total = 0.0
	for event in events:
		total += event["chance"]
	
	var roll = randf() * total
	var cumulative = 0.0
	
	for event in events:
		cumulative += event["chance"]
		if roll <= cumulative:
			return event
	
	return {"type": "none", "text": "", "chance": 0.0}

# Menu easter eggs
var menu_codes = {
	"UP UP DOWN DOWN LEFT RIGHT LEFT RIGHT B A": {
		"effect": "secret_unlocked",
		"message": "¡Código secreto activado!\n🔓 Modo Debug Desbloqueado"
	},
	"fancy": {
		"effect": "fancy_mode",
		"message": "¡Modo Fancy Activado!\n✨ Todo brilla más"
	},
	"dark": {
		"effect": "dark_mode",
		"message": "Modo Oscuro Activado\n🌑 Los secretos emergen"
	},
	"undertale": {
		"effect": "classic_theme",
		"message": "🎵 Tema Clásico\nInspirado en Toby Fox"
	}
}

var entered_code = ""

func check_konami_code(key: String) -> bool:
	entered_code += key
	if entered_code.length() > 50:
		entered_code = entered_code.substr(-50)
	
	if "UUDDLRLRBA" in entered_code.to_upper():
		entered_code = ""
		return true
	return false

# Random battle introductions
var battle_intros = [
	"* Un monstruo aparece!",
	"* ¡El destino te alcanza!",
	"* Algo se mueve en las sombras...",
	"* ¡Un enemigo bloquea tu camino!",
	"* Una presencia oscura se manifiesta...",
	"* ¡Prepárate para battle!",
	"* Los shadows se unen para fightearte!",
	"* Un ser emerge de la oscuridad...",
]

func get_battle_intro() -> String:
	return battle_intros[randi() % battle_intros.size()]

# Random victory messages
var victory_messages = [
	"* But it refused.",
	"* ...No, it wasn't even trying.",
	"* The enemy barely tried to fight back.",
	"* ¡Victoria aplastante!",
	"* Another monster falls before you.",
	"* The darkness retreats... por ahora.",
	"* But nobody came.",
	"* Your determination grows.",
]

func get_victory_message() -> String:
	return victory_messages[randi() % victory_messages.size()]

# Secret endings
var secret_phrases = [
	"have_a_nice_day",
	"thank_you_for_playing",
	"even_in_darkness",
	"determination",
	"love_and_determination",
]

func check_secret_phrase(phrase: String) -> bool:
	return secret_phrases.has(phrase.to_lower())
