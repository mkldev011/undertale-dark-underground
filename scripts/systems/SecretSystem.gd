extends Node

# SecretSystem.gd
# Hidden secrets, easter eggs, and unlockables

signal secret_found(secret_id: String)
signal achievement_unlocked(achievement_id: String)

var discovered_secrets: Array = []
var unlocked_achievements: Array = []
var secret_flags: Dictionary = {}

var secrets = {
	"flowey_laugh": {
		"name": "Risa de Flowey",
		"description": "Flowey se rió 13 veces.",
		"reward": "Aceptas la oscuridad."
	},
	"sans_judge": {
		"name": "El Juicio de Sans",
		"description": "Sans te juzgó en el pasillo.",
		"reward": "Increíbles 0 juicios."
	},
	"secret_room": {
		"name": "Habitación Secreta",
		"description": "Encontraste la habitación oculta.",
		"reward": "Un tesoro especial."
	},
	"true_ending": {
		"name": "Verdadero Final",
		"description": "Alcanzaste el ending verdadero.",
		"reward": "Todo cambió."
	},
	"no_kills": {
		"name": "Pacificista",
		"description": "Completaste sin matar a nadie.",
		"reward": "Tu determinación es mayor."
	},
	"all_spare": {
		"name": "Amigo de Todos",
		"description": "Te hiciste amigo de todos.",
		"reward": "Los monstruos te respetan."
	},
	"speedrun": {
		"name": "Velocista",
		"description": "Completaste el capítulo en menos de 30 minutos.",
		"reward": "La velocidad importa."
	},
	"collector": {
		"name": "Coleccionista",
		"description": "Collectaste todos los objetos.",
		"reward": "Tu inventario está lleno."
	},
	"secret_boss_defeated": {
		"name": "Cazador de Sombras",
		"description": "Derrotaste al Guardián de las Sombras.",
		"reward": "La luz prevalece."
	},
	"dark_truth": {
		"name": "Verdad Oscura",
		"description": "Descubriste la verdad sobre los fountains.",
		"reward": "El mundo es más profundo."
	}
}

var achievements = {
	"first_battle": {
		"name": "Primera Batalla",
		"description": "Luchaste en tu primer batalla."
	},
	"first_victory": {
		"name": "Primera Victoria",
		"description": "Ganaste tu primer batalla."
	},
	"first_spare": {
		"name": "Amigo",
		"description": " perdonaste a un enemigo por primera vez."
	},
	"first_death": {
		"name": "Aprendiz",
		"description": "Moriste... pero aprendiste."
	},
	"first_save": {
		"name": "Guardado",
		"description": "Guardaste tu progreso por primera vez."
	},
	"chapter_1_complete": {
		"name": "Cap. 1 Completo",
		"description": "Completaste el Capítulo 1."
	},
	"secret_found": {
		"name": "Curioso",
		"description": "Encontraste un secreto."
	},
	"all_secrets": {
		"name": "Explorador Total",
		"description": "Encontraste todos los secretos."
	},
	"hard_mode": {
		"name": "Modo Difícil",
		"description": "Jugaste en modo difícil."
	},
	"no_hits": {
		"name": "Perfecto",
		"description": "Ganaste una batalla sin recibir daño."
	}
}

func discover_secret(secret_id: String) -> bool:
	if secret_id in discovered_secrets:
		return false
	
	discovered_secrets.append(secret_id)
	secret_found.emit(secret_id)
	
	var secret = secrets.get(secret_id, {})
	var name = secret.get("name", secret_id)
	var reward = secret.get("reward", "Algo ha cambiado...")
	
	_show_secret_popup(name, reward)
	
	return true

func unlock_achievement(achievement_id: String) -> bool:
	if achievement_id in unlocked_achievements:
		return false
	
	unlocked_achievements.append(achievement_id)
	achievement_unlocked.emit(achievement_id)
	
	var achievement = achievements.get(achievement_id, {})
	var name = achievement.get("name", achievement_id)
	
	_show_achievement_popup(name)
	
	return true

func _show_secret_popup(name: String, reward: String) -> void:
	# Create popup
	var popup = AcceptDialog.new()
	popup.dialog_text = "🔓 SECRETO DESCUBIERTO!\n\n%s\n\n%s" % [name, reward]
	popup.ok_button_text = "Increíble"
	
	var root = Engine.get_main_loop().root
	root.add_child(popup)
	popup.popup_centered()

func _show_achievement_popup(name: String) -> void:
	var popup = AcceptDialog.new()
	popup.dialog_text = "🏆 LOGRO DESBLOQUEADO!\n\n%s" % name
	popup.ok_button_text = "¡Genial!"
	
	var root = Engine.get_main_loop().root
	root.add_child(popup)
	popup.popup_centered()

# Secret locations
var secret_locations = {
	"hidden_wall_1": {
		"position": Vector2(100, 200),
		"requirement": "examine_wall",
		"contains": "secret_item"
	},
	"hidden_room": {
		"position": Vector2(500, 350),
		"requirement": "push_boulder",
		"contains": "secret_enemy"
	},
	"secret_passage": {
		"position": Vector2(800, 400),
		"requirement": "jump_3_times",
		"contains": "bonus_area"
	}
}

# Check if player can access secret
func can_access_secret(secret_id: String) -> bool:
	var secret = secret_locations.get(secret_id, {})
	var requirement = secret.get("requirement", "")
	
	match requirement:
		"examine_wall":
			return true  # Always available
		"push_boulder":
			return true  # TODO: Check boulder position
		"jump_3_times":
			return true  # TODO: Check jump count
		_:
			return true

# Random chance secrets
func check_random_secret() -> void:
	var roll = randf()
	
	if roll < 0.01:  # 1% chance
		discover_secret("secret_room")
	elif roll < 0.02:  # 1% chance
		unlock_achievement("secret_found")

# Debug secrets
var debug_secrets_enabled: bool = false

func enable_debug_secrets() -> void:
	debug_secrets_enabled = true
	print("🔓 Debug secrets enabled!")

func get_all_secrets_status() -> Dictionary:
	var status = {}
	for secret_id in secrets.keys():
		status[secret_id] = secret_id in discovered_secrets
	return status

func get_all_achievements_status() -> Dictionary:
	var status = {}
	for achievement_id in achievements.keys():
		status[achievement_id] = achievement_id in unlocked_achievements
	return status
