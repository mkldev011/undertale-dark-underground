extends Node2D

# CompleteMap.gd
# Full Undertale-style map with all locations

# Map Areas (matching original Undertale layout)
enum Area {
	# RUINS (Starting Area)
	RUINS_ENTRANCE,      # Where you fall
	RUINS_CAVE,           # First room with leaves
	RUINS_SPIDER,         # Spider bake sale area
	RUINS_DOG,            # Dog/ Dummy room
	RUINS_ROOM1,          # First puzzle room
	RUINS_ROOM2,          # Second puzzle room
	RUINS_ROOM3,          # Third puzzle room
	RUINS_LONG,           # Long corridor
	RUINS_TORIEL_HOME,    # Toriel's house (END OF CHAPTER 1)
	
	# SNOWDIN
	SNOWDIN_FOREST_ENTRANCE,
	SNOWDIN_FOREST,
	SNOWDIN_TOWN,
	SNOWDIN_PAPYRUS_HOUSE,
	SNOWDIN_SANS_ROOM,
	SNOWDIN_STORE,
	SNOWDIN_GRILLBY,
	
	# WATERFALL
	WATERFALL_ENTRANCE,
	WATERFALL_ONGUARD,
	WATERFALL_KNOCK,
	WATERFALL_UNDYNE_FIGHT,
	WATERFALL_HOTEL,
	WATERFALL_UNDYNE_CAVE,
	WATERFALL_SECRET,
	
	# HOTLAND
	HOTLAND_ENTRANCE,
	HOTLAND_CORE,
	HOTLAND_LAB,
	HOTLAND_MTT,
	HOTLAND_TRAM,
	HOTLAND_FIRE Element_PUZZLE,
	HOTLAND_ALPHYS_LAB,
	
	# NEW HOME
	NEW_HOME_ENTRANCE,
	NEW_HOME_THRONE,
	
	# BOSS AREAS
	BOSS_ASGORE,
	BOSS_FLOWEY,
	
	# DARK WORLD
	DARK_RUINS,
	DARK_SNOWDIN,
	DARK_WATERFALL,
	DARK_HOTLAND
}

# Current state
var current_area: Area = Area.RUINS_ENTRANCE
var area_flags: Dictionary = {}

# NPCs in each area
var area_npcs: Dictionary = {
	Area.RUINS_ENTRANCE: ["flowey"],
	Area.RUINS_TORIEL_HOME: ["toriel"],
	Area.SNOWDIN_TOWN: ["sans", "papyrus"],
	Area.SNOWDIN_STORE: ["brandon"],
	Area.WATERFALL_UNDYNE_FIGHT: ["undyne"],
	Area.HOTLAND_MTT: ["mettabot"],
	Area.NEW_HOME_THRONE: ["asgore"],
}

# Enemies in each area
var area_enemies: Dictionary = {
	Area.RUINS_ENTRANCE: [],
	Area.RUINS_CAVE: ["froggit"],
	Area.RUINS_SPIDER: ["whimsun"],
	Area.RUINS_ROOM1: [],
	Area.RUINS_ROOM2: ["froggit", "loox"],
	Area.SNOWDIN_FOREST: ["ice_cap"],
	Area.WATERFALL_ENTRANCE: ["moldsmal"],
	Area.HOTLAND_CORE: ["guard"],
}

# Exit connections (from -> [to, position])
var exits: Dictionary = {
	Area.RUINS_ENTRANCE: [Area.RUINS_CAVE, Vector2(640, 600)],
	Area.RUINS_CAVE: [
		[Area.RUINS_ENTRANCE, Vector2(640, 100)],
		[Area.RUINS_SPIDER, Vector2(200, 400)],
		[Area.RUINS_DOG, Vector2(1100, 400)]
	],
	Area.RUINS_SPIDER: [
		[Area.RUINS_CAVE, Vector2(900, 400)]
	],
	Area.RUINS_DOG: [
		[Area.RUINS_CAVE, Vector2(100, 400)]
	],
	Area.RUINS_ROOM1: [
		[Area.RUINS_CAVE, Vector2(640, 100)],
		[Area.RUINS_ROOM2, Vector2(640, 600)]
	],
	Area.RUINS_ROOM2: [
		[Area.RUINS_ROOM1, Vector2(640, 100)],
		[Area.RUINS_ROOM3, Vector2(640, 600)]
	],
	Area.RUINS_ROOM3: [
		[Area.RUINS_ROOM2, Vector2(640, 100)],
		[Area.RUINS_LONG, Vector2(640, 600)]
	],
	Area.RUINS_LONG: [
		[Area.RUINS_ROOM3, Vector2(640, 100)],
		[Area.RUINS_TORIEL_HOME, Vector2(640, 600)]
	],
	Area.RUINS_TORIEL_HOME: [
		[Area.RUINS_LONG, Vector2(640, 100)],
		[Area.SNOWDIN_FOREST_ENTRANCE, Vector2(640, 600)]
	],
	Area.SNOWDIN_FOREST_ENTRANCE: [
		[Area.RUINS_TORIEL_HOME, Vector2(640, 100)],
		[Area.SNOWDIN_FOREST, Vector2(640, 600)]
	],
	Area.SNOWDIN_FOREST: [
		[Area.SNOWDIN_FOREST_ENTRANCE, Vector2(640, 100)],
		[Area.SNOWDIN_TOWN, Vector2(640, 600)]
	],
	Area.SNOWDIN_TOWN: [
		[Area.SNOWDIN_FOREST, Vector2(640, 100)],
		[Area.WATERFALL_ENTRANCE, Vector2(640, 600)]
	],
	Area.WATERFALL_ENTRANCE: [
		[Area.SNOWDIN_TOWN, Vector2(640, 100)]
	],
	Area.NEW_HOME_ENTRANCE: [
		[Area.HOTLAND_CORE, Vector2(640, 100)]
	],
	Area.NEW_HOME_THRONE: [
		[Area.BOSS_ASGORE, Vector2(640, 400)]
	],
}

# Dark Fountain locations
var dark_fountains: Dictionary = {
	Area.RUINS_LONG: {"found": false, "sealed": false},
	Area.SNOWDIN_FOREST: {"found": false, "sealed": false},
	Area.WATERFALL_ENTRANCE: {"found": false, "sealed": false},
	Area.HOTLAND_CORE: {"found": false, "sealed": false},
}

# Progress tracking
var fountains_sealed: int = 0
var chapter_progress: float = 0.0

func _ready() -> void:
	# Load progress
	_load_progress()

func _load_progress() -> void:
	fountains_sealed = GlobalVariables.get_flag("fountains_sealed_count")
	chapter_progress = fountains_sealed / 7.0  # 7 fountains total

func _save_progress() -> void:
	GlobalVariables.set_flag("fountains_sealed_count", fountains_sealed)

# Area navigation
func get_current_area() -> Area:
	return current_area

func move_to_area(new_area: Area) -> void:
	if exits.has(current_area):
		var possible_exits = exits[current_area]
		for exit_data in possible_exits:
			if exit_data[0] == new_area:
				current_area = new_area
				chapter_progress = current_area / float(Area.size())
				return
	
	# Direct area change (for story events)
	current_area = new_area

# Check for dark fountain
func check_dark_fountain() -> bool:
	if dark_fountains.has(current_area):
		var fountain = dark_fountains[current_area]
		return fountain.get("found", false) and not fountain.get("sealed", false)
	return false

# Seal a dark fountain
func seal_dark_fountain() -> void:
	if dark_fountains.has(current_area):
		dark_fountains[current_area]["sealed"] = true
		fountains_sealed += 1
		_save_progress()
		
		# Check for chapter completion
		if fountains_sealed >= 7:
			_trigger_true_ending()
		elif current_area == Area.RUINS_LONG and fountains_sealed == 1:
			_trigger_chapter_1_end()

# Chapter 1 ends in Toriel's house
func _trigger_chapter_1_end() -> void:
	GlobalVariables.set_flag("chapter1_complete")
	chapter_progress = 1.0

# True ending when all fountains are sealed
func _trigger_true_ending() -> void:
	GlobalVariables.set_flag("true_ending_unlocked")

# Get area info
func get_area_info() -> Dictionary:
	var info = {
		"name": Area.keys()[current_area].replace("_", " "),
		"npcs": area_npcs.get(current_area, []),
		"enemies": area_enemies.get(current_area, []),
		"has_fountain": check_dark_fountain(),
		"progress": chapter_progress
	}
	return info

# Puzzle state
var puzzles_solved: Dictionary = {}

func is_puzzle_solved(puzzle_id: String) -> bool:
	return puzzles_solved.get(puzzle_id, false)

func solve_puzzle(puzzle_id: String) -> void:
	puzzles_solved[puzzle_id] = true

# Get map description for UI
func get_map_name() -> String:
	match current_area:
		Area.RUINS_ENTRANCE: return "Entrance"
		Area.RUINS_TORIEL_HOME: return "Toriel's House"
		Area.SNOWDIN_TOWN: return "Snowdin Town"
		Area.WATERFALL_ENTRANCE: return "Waterfall"
		Area.HOTLAND_CORE: return "Hotland"
		Area.NEW_HOME_THRONE: return "New Home"
		_: return Area.keys()[current_area].replace("_", " ")
