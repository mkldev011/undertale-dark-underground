extends Node

# SaveSystem.gd
# Handles all game saving and loading operations

const SAVE_DIR = "user://saves/"
const MAX_SAVE_SLOTS = 3

var current_save_slot: int = 0
var is_save_locked: bool = false  # Prevents saving during battles/cutscenes

func _ready() -> void:
	# Ensure save directory exists
	DirAccess.make_dir_recursive_absolute(SAVE_DIR.get_base_dir())

# Save data to a specific slot
func save_game(slot: int = 0, file_name: String = "savegame.sav") -> bool:
	if is_save_locked:
		print("Cannot save: Save is locked during battle/cutscene")
		return false
	
	var save_data = _collect_save_data()
	var file_path = SAVE_DIR + "slot_%d_%s" % [slot, file_name]
	
	var save_file = FileAccess.open(file_path, FileAccess.WRITE)
	if save_file == null:
		push_error("Failed to open save file for writing: " + file_path)
		return false
	
	var json_string = JSON.stringify(save_data, "\t")
	save_file.store_line(json_string)
	save_file.close()
	
	print("Game saved to slot %d" % slot)
	return true

# Load data from a specific slot
func load_game(slot: int = 0, file_name: String = "savegame.sav") -> Dictionary:
	var file_path = SAVE_DIR + "slot_%d_%s" % [slot, file_name]
	
	if not FileAccess.file_exists(file_path):
		push_warning("Save file does not exist: " + file_path)
		return {}
	
	var save_file = FileAccess.open(file_path, FileAccess.READ)
	if save_file == null:
		push_error("Failed to open save file for reading: " + file_path)
		return {}
	
	var json_string = save_file.get_line()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse save file JSON")
		return {}
	
	print("Game loaded from slot %d" % slot)
	return json.data

# Check if a save file exists
func save_exists(slot: int = 0, file_name: String = "savegame.sav") -> bool:
	var file_path = SAVE_DIR + "slot_%d_%s" % [slot, file_name]
	return FileAccess.file_exists(file_path)

# Delete a save file
func delete_save(slot: int = 0, file_name: String = "savegame.sav") -> bool:
	var file_path = SAVE_DIR + "slot_%d_%s" % [slot, file_name]
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		print("Save deleted from slot %d" % slot)
		return true
	return false

# Get info about all save slots
func get_save_info() -> Array[Dictionary]:
	var saves = []
	for i in range(MAX_SAVE_SLOTS):
		if save_exists(i):
			var data = load_game(i)
			saves.append({
				"slot": i,
				"exists": true,
				"timestamp": data.get("timestamp", 0),
				"play_time": data.get("play_time", 0.0),
				"chapter": data.get("chapter", 1),
				"location": data.get("location", "Unknown"),
				"level": data.get("party_stats", {}).get("frisk", {}).get("level", 1)
			})
		else:
			saves.append({
				"slot": i,
				"exists": false
			})
	return saves

# Collect all data needed for saving
func _collect_save_data() -> Dictionary:
	var save_data = {
		"version": "1.0.0",
		"timestamp": Time.get_unix_time_from_system(),
		"play_time": GlobalVariables.total_play_time,
		"chapter": GlobalVariables.current_chapter,
		"location": get_current_location_name(),
		
		# Scene info
		"scene_path": GameManager.current_scene_path,
		"player_position": _get_player_save_data(),
		
		# Party and stats
		"party": GlobalVariables.party,
		"party_stats": GlobalVariables.character_stats,
		
		# Inventory
		"inventory": GlobalVariables.inventory,
		"gold": GlobalVariables.gold,
		
		# Game flags
		"flags": GlobalVariables.game_flags,
		
		# Quests
		"quests": GlobalVariables.active_quests,
		"completed_quests": GlobalVariables.completed_quests,
		
		# Relationships (for character interactions)
		"relationships": GlobalVariables.relationships
	}
	
	return save_data

# Get player position data
func _get_player_save_data() -> Dictionary:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		return {
			"x": player.global_position.x,
			"y": player.global_position.y,
			"facing": player.facing_direction
		}
	return {"x": 0, "y": 0, "facing": 1}

# Get current location name for save file
func get_current_location_name() -> String:
	var scene_name = GameManager.current_scene_path.get_file().get_basename()
	return scene_name

# Apply loaded data to game state
func apply_save_data(save_data: Dictionary) -> void:
	# Reset current state
	GlobalVariables.reset_state()
	
	# Apply loaded data
	GlobalVariables.total_play_time = save_data.get("play_time", 0.0)
	GlobalVariables.current_chapter = save_data.get("chapter", 1)
	GlobalVariables.party = save_data.get("party", ["Frisk"])
	GlobalVariables.character_stats = save_data.get("party_stats", {})
	GlobalVariables.inventory = save_data.get("inventory", [])
	GlobalVariables.gold = save_data.get("gold", 0)
	GlobalVariables.game_flags = save_data.get("flags", {})
	GlobalVariables.active_quests = save_data.get("quests", [])
	GlobalVariables.completed_quests = save_data.get("completed_quests", [])
	GlobalVariables.relationships = save_data.get("relationships", {})

# Generic save/load for any data
func save_data(path: String, data: Dictionary) -> bool:
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	if save_file == null:
		return false
	
	var json_string = JSON.stringify(data, "\t")
	save_file.store_line(json_string)
	save_file.close()
	return true

func load_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	
	var save_file = FileAccess.open(path, FileAccess.READ)
	if save_file == null:
		return {}
	
	var json_string = save_file.get_line()
	var json = JSON.new()
	if json.parse(json_string) == OK:
		return json.data
	return {}
