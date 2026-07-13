extends Node

# PuzzleSystem.gd
# Simple puzzles for the game

signal puzzle_solved(puzzle_id: String)
signal puzzle_failed(puzzle_id: String)

# Puzzle definitions
var puzzles: Dictionary = {
	"ruins_lever": {
		"name": "La Palanca",
		"description": "Hay una palanca en la pared. ¿Qué dirección?",
		"type": "binary",
		"solution": "right",
		"hint": "La puerta parece pesada. Quizás需要一个 empujón fuerte.",
		"reward": " Acceso a la siguiente sala"
	},
	"ruins_switches": {
		"name": "Los Interruptores",
		"description": "Cuatro interruptores... ¿en qué orden?",
		"type": "sequence",
		"solution": [true, false, true, true],
		"hint": "Las marcas en la pared muestran un patrón.",
		"reward": "El puente se levanta"
	},
	"ruins_rocks": {
		"name": "El Puzzle de Rocas",
		"description": "Presiona las rocas en el orden correcto.",
		"type": "order",
		"solution": [1, 2, 3, 4],
		"hint": "Los números están borrosos, pero puedes ver el orden.",
		"reward": "El suelo se mueve"
	},
	"snowdin_signs": {
		"name": "El Puzzle de Señales",
		"description": "Las señales de Snowdin apuntan diferentes direcciones.",
		"type": "path",
		"solution": ["left", "right", "left"],
		"hint": "Siempre vuelve al principio si te equivocas.",
		"reward": "Encuentras el pueblo"
	},
	"waterfall_dark": {
		"name": "La Habitación Oscura",
		"description": "Está muy oscuro... necesitas encontrar los interruptores.",
		"type": "memory",
		"solution": [true, false, true, false],
		"hint": "Recuerda dónde viste las luces.",
		"reward": "La habitación se ilumina"
	},
	"hotland_lava": {
		"name": "Cruza el Lava",
		"description": "Presiona los botones en el orden correcto para crear un camino.",
		"type": "timing",
		"solution": [0, 2, 4, 1],
		"hint": "Los números brillan en secuencia.",
		"reward": "Un puente aparece"
	}
}

# Current puzzle state
var current_puzzle: String = ""
var puzzle_attempts: int = 0
var puzzle_state: Array = []

func start_puzzle(puzzle_id: String) -> bool:
	if not puzzles.has(puzzle_id):
		return false
	
	current_puzzle = puzzle_id
	puzzle_attempts = 0
	puzzle_state = []
	return true

func get_puzzle_info() -> Dictionary:
	if current_puzzle == "":
		return {}
	return puzzles[current_puzzle]

func attempt_solution(attempt: Variant) -> bool:
	if current_puzzle == "":
		return false
	
	puzzle_attempts += 1
	var puzzle = puzzles[current_puzzle]
	
	var is_correct = false
	
	match puzzle["type"]:
		"binary":
			is_correct = attempt == puzzle["solution"]
		"sequence":
			puzzle_state.append(attempt)
			is_correct = puzzle_state == puzzle["solution"]
		"order":
			puzzle_state.append(attempt)
			is_correct = puzzle_state == puzzle["solution"]
		"path":
			puzzle_state.append(attempt)
			is_correct = puzzle_state == puzzle["solution"]
		"memory":
			puzzle_state.append(attempt)
			is_correct = puzzle_state == puzzle["solution"]
		"timing":
			is_correct = attempt == puzzle["solution"]
	
	if is_correct:
		puzzle_solved.emit(current_puzzle)
		current_puzzle = ""
		return true
	else:
		# Reset if wrong
		puzzle_state = []
		if puzzle_attempts >= 3:
			puzzle_failed.emit(current_puzzle)
		return false

func get_hint() -> String:
	if current_puzzle == "":
		return ""
	return puzzles[current_puzzle].get("hint", "No hay pista disponible.")

func cancel_puzzle() -> void:
	current_puzzle = ""
	puzzle_state = []
	puzzle_attempts = 0

# Interactive puzzle room script
class PuzzleRoom:
	extends Node2D
	
	signal puzzle_completed
	
	@export var puzzle_id: String = ""
	@export var puzzle_type: String = "binary"
	
	var is_active: bool = false
	var solved: bool = false
	
	func activate():
		is_active = true
	
	func deactivate():
		is_active = false
	
	func check_solution(solution: Variant) -> bool:
		if solved:
			return true
		# Check with puzzle system
		return false

# Simple lever puzzle
class LeverPuzzle:
	extends Node2D
	
	var lever_position: bool = false  # false = left, true = right
	var is_interactive: bool = true
	
	func interact():
		lever_position = !lever_position
		_update_visual()
	
	func _update_visual():
		# Update sprite based on position
		pass
	
	func is_solved() -> bool:
		return lever_position  # Must be in "right" position

# Switch puzzle with multiple switches
class SwitchPuzzle:
	extends Node2D
	
	var switches: Array = [false, false, false, false]
	var target_sequence: Array = []
	var current_input: Array = []
	
	func set_target(sequence: Array):
		target_sequence = sequence
	
	func toggle_switch(index: int):
		if index < switches.size():
			switches[index] = !switches[index]
			current_input.append(switches[index])
			_check_solution()
	
	func _check_solution():
		if current_input == target_sequence:
			solved.emit()
	
	func reset():
		switches = [false, false, false, false]
		current_input = []

# Rock puzzle - press in order
class RockPuzzle:
	extends Node2D
	
	var rocks: Array = []
	var correct_order: Array = []
	var current_order: Array = []
	
	func setup(rocks_array: Array, order: Array):
		rocks = rocks_array
		correct_order = order
	
	func press_rock(index: int):
		current_order.append(index)
		_animate_rock(rocks[index])
		_check_order()
	
	func _animate_rock(rock):
		# Rock press animation
		pass
	
	func _check_order():
		if current_order == correct_order:
			solved.emit()

# Save puzzle progress
var puzzle_progress: Dictionary = {}

func save_progress() -> void:
	GlobalVariables.set_flag("puzzle_progress", puzzle_progress)

func load_progress() -> void:
	puzzle_progress = GlobalVariables.get_flag("puzzle_progress", {})

func is_puzzle_solved(puzzle_id: String) -> bool:
	return puzzle_progress.get(puzzle_id, false)

func mark_puzzle_solved(puzzle_id: String) -> void:
	puzzle_progress[puzzle_id] = true
	save_progress()
