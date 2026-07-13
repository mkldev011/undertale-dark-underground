extends Node

# GlobalVariables.gd
# Stores all persistent game state that needs to be shared across scenes

signal flag_changed(flag_name: String, value)
signal party_changed(new_party: Array)
signal inventory_changed(new_inventory: Array)
signal gold_changed(new_gold: int)

# ============ GAME PROGRESSION ============

var total_play_time: float = 0.0
var current_chapter: int = 1
var current_act: int = 1

# ============ PLAYER DATA ============

# Current party members
var party: Array = ["Frisk"]

# Character stats by name
var character_stats: Dictionary = {
	"Frisk": {
		"hp": 20,
		"max_hp": 20,
		"attack": 10,
		"defense": 10,
		"level": 1,
		"exp": 0,
		"weapon": "stick",
		"armor": "bandage",
		"xp_bar": 0,
		"love": 1
	},
	"Kris": {
		"hp": 22,
		"max_hp": 22,
		"attack": 11,
		"defense": 10,
		"level": 1,
		"exp": 0,
		"weapon": "none",
		"armor": "none"
	},
	"Ralsei": {
		"hp": 18,
		"max_hp": 18,
		"attack": 8,
		"defense": 12,
		"level": 1,
		"exp": 0,
		"weapon": "raclette_dagger",
		"armor": "dark_robe",
		"is_darkner": true
	},
	" Susie": {
		"hp": 25,
		"max_hp": 25,
		"attack": 14,
		"defense": 8,
		"level": 1,
		"exp": 0,
		"weapon": "axe",
		"armor": "none"
	},
	"Sans": {
		"hp": 1,  # Canonically 1 HP
		"max_hp": 1,
		"attack": 1,
		"defense": 1,
		"level": 1,
		"is_boss": true
	},
	"Papyrus": {
		"hp": 680,
		"max_hp": 680,
		"attack": 20,
		"defense": 20,
		"level": 12
	},
	"Tori": {
		"hp": 680,
		"max_hp": 680,
		"attack": 18,
		"defense": 25,
		"level": 15
	}
}

# Inventory system
var inventory: Array = []
var gold: int = 0
var max_inventory_slots: int = 20

# ============ GAME FLAGS ============

# Flags for story progression and conditions
var game_flags: Dictionary = {}

# Quest tracking
var active_quests: Array = []
var completed_quests: Array = []

# ============ RELATIONSHIP SYSTEM ============

# Tracks relationship levels with characters
var relationships: Dictionary = {
	"Sans": {"score": 0, "tolerance": 0, "met": false},
	"Papyrus": {"score": 0, "tolerance": 0, "met": false},
	"Tori": {"score": 0, "tolerance": 0, "met": false},
	"Undyne": {"score": 0, "tolerance": 0, "met": false},
	"Alphys": {"score": 0, "tolerance": 0, "met": false},
	"Mettaton": {"score": 0, "tolerance": 0, "met": false},
	"Asgore": {"score": 0, "tolerance": 0, "met": false},
	"Flowey": {"score": 0, "tolerance": 0, "met": false},
	"Ralsei": {"score": 0, "tolerance": 0, "met": false},
	"Kris": {"score": 0, "tolerance": 0, "met": false},
	"Susie": {"score": 0, "tolerance": 0, "met": false},
	"Noelle": {"score": 0, "tolerance": 0, "met": false},
	"Berdly": {"score": 0, "tolerance": 0, "met": false}
}

# ============ WORLD STATE ============

# Current area and room
var current_area: String = "ruins_entrance"
var visited_areas: Array = []
var unlocked_areas: Array = ["ruins_entrance"]

# ============ UTILITY FUNCTIONS ============

func _process(delta: float) -> void:
	total_play_time += delta

# Flag management
func set_flag(flag_name: String, value = true) -> void:
	game_flags[flag_name] = value
	flag_changed.emit(flag_name, value)

func get_flag(flag_name: String, default_value = false):
	return game_flags.get(flag_name, default_value)

func has_flag(flag_name: String) -> bool:
	return flag_name in game_flags

func remove_flag(flag_name: String) -> void:
	game_flags.erase(flag_name)

# Party management
func add_to_party(character: String) -> void:
	if character not in party and party.size() < 3:
		party.append(character)
		party_changed.emit(party)

func remove_from_party(character: String) -> void:
	if character in party and character != "Frisk":
		party.erase(character)
		party_changed.emit(party)

func is_in_party(character: String) -> bool:
	return character in party

# Inventory management
func add_item(item_id: String, amount: int = 1) -> bool:
	if inventory.size() >= max_inventory_slots:
		return false
	inventory.append(item_id)
	inventory_changed.emit(inventory)
	return true

func remove_item(item_id: String, amount: int = 1) -> bool:
	for i in range(amount):
		if item_id in inventory:
			inventory.erase(item_id)
	inventory_changed.emit(inventory)
	return true

func has_item(item_id: String) -> bool:
	return item_id in inventory

func get_item_count(item_id: String) -> int:
	var count = 0
	for item in inventory:
		if item == item_id:
			count += 1
	return count

# Gold management
func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		return true
	return false

# Character stat management
func heal_character(character: String, amount: int = -1) -> void:
	if not character_stats.has(character):
		return
	
	if amount == -1:
		# Full heal
		character_stats[character]["hp"] = character_stats[character]["max_hp"]
	else:
		character_stats[character]["hp"] = min(
			character_stats[character]["hp"] + amount,
			character_stats[character]["max_hp"]
		)

func heal_full() -> void:
	for character in character_stats:
		character_stats[character]["hp"] = character_stats[character]["max_hp"]

func damage_character(character: String, amount: int) -> void:
	if not character_stats.has(character):
		return
	character_stats[character]["hp"] = max(1, character_stats[character]["hp"] - amount)

func is_character_alive(character: String) -> bool:
	return character_stats.get(character, {}).get("hp", 0) > 0

# Relationship management
func modify_relationship(character: String, score_change: int, tolerance_change: int = 0) -> void:
	if not relationships.has(character):
		relationships[character] = {"score": 0, "tolerance": 0, "met": true}
	
	relationships[character]["score"] += score_change
	relationships[character]["tolerance"] += tolerance_change
	relationships[character]["met"] = true
	
	# Clamp values
	relationships[character]["score"] = clamp(relationships[character]["score"], -100, 100)
	relationships[character]["tolerance"] = clamp(relationships[character]["tolerance"], -100, 100)

func get_relationship(character: String) -> Dictionary:
	return relationships.get(character, {"score": 0, "tolerance": 0, "met": false})

# Quest management
func add_quest(quest_id: String) -> void:
	if quest_id not in active_quests and quest_id not in completed_quests:
		active_quests.append(quest_id)

func complete_quest(quest_id: String) -> void:
	if quest_id in active_quests:
		active_quests.erase(quest_id)
		completed_quests.append(quest_id)

func has_quest(quest_id: String) -> bool:
	return quest_id in active_quests

func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests

# Area tracking
func visit_area(area_id: String) -> void:
	if area_id not in visited_areas:
		visited_areas.append(area_id)

func unlock_area(area_id: String) -> void:
	if area_id not in unlocked_areas:
		unlocked_areas.append(area_id)

func is_area_unlocked(area_id: String) -> bool:
	return area_id in unlocked_areas

# Reset functions
func reset_state() -> void:
	game_flags.clear()
	party = ["Frisk"]
	inventory.clear()
	gold = 0
	active_quests.clear()
	visited_areas.clear()
	
	# Reset character stats to defaults
	character_stats["Frisk"]["hp"] = character_stats["Frisk"]["max_hp"]

func reset_all_progress() -> void:
	reset_state()
	total_play_time = 0.0
	current_chapter = 1
	current_act = 1
	completed_quests.clear()
	relationships.clear()
	for character in relationships:
		relationships[character] = {"score": 0, "tolerance": 0, "met": false}
