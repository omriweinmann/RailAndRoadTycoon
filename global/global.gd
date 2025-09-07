extends Node

var debug = false

var road_changers = [0,3]

var width:int = 375
var height:int = 375
var altitude:float = 0

var sprite = []
var loaded_sprite = []

var done_loading = false

var industries_per_100 = 5

var seed:int = -1

var error_pop_up = {"Title": "Nil", "Description": "Nil"}

var mouse_in_menu = false

var built:Array = []
var built_data:Array = []

var building_id_selected = -1

var building_source = [
	[
		"Road", # Real Name
		"res://asset/pictures/buildings/roads/RoadOrientation", # File Location
		".png", # File Format
		true, # Removable
		[], # Procedu-Generated (Check Power Plant for true)
		0, # ZIndex
	],
	[
		"Power Plant",
		"res://asset/pictures/buildings/PowerPlant",
		".png",
		false,
		[ # True P-G
			50, # Social Distancing - New industries can not be place with in _ of this industry
			[8,2], # Extra (places more industies of the same type around) (How many, How far)
			[
				"res://asset/pictures/buildings/PowerPlant0.png",
				"res://asset/pictures/buildings/PowerPlant1.png",
				"res://asset/pictures/buildings/PowerPlant2.png",
				"res://asset/pictures/buildings/PowerPlant3.png",
				"res://asset/pictures/buildings/PowerPlant4.png",
			], # Sprites For Extra
			false, # Pollutes
			-1, #Connects to, (what industry to auto gen next)
		],
		1,
	],
	[
		"Coal Mine",
		"res://asset/pictures/buildings/CoalMine",
		".png",
		false,
		[
			75,
			[5,2],
			[
				"res://asset/pictures/buildings/CoalMine0.png",
				"res://asset/pictures/buildings/CoalMine1.png"
			],
			true, # Pollutes
			1, #Connects to, (what industry to auto gen next)
		],
		1,
	],
	[
		"Warehouse", # Real Name
		"res://asset/pictures/buildings/Warehouse", # File Location
		".png", # File Format
		true, # Removable
		[], # Procedu-Generated (Check Power Plant for true)
		1, # ZIndex
	],
]

var proc_buildings = [2]

func _build(coords:Vector2i,_coords_local):
	if not building_id_selected == -1:
		var find = built.find(coords)
		#print(find,",",coords)
		if building_id_selected == -2 and not find == -1:
			return _remove(find)
		elif not building_id_selected == -2:
			var get_from_source = building_source[building_id_selected]
			if find == -1:
				built.push_front(coords)
				built_data.push_front(
					[
						get_from_source[0],
						building_id_selected
					]
				)
			else:
				built_data[find] = [
					get_from_source[0],
					built_data[find][1]
				]
				#print(built_data[find])
			#print(get_from_source[3])
			#print(built,built_data)
			return find
	return -3
func _remove(array_location):
	if building_source[built_data[array_location][1]][3] == true:
		built.remove_at(array_location)
		built_data.remove_at(array_location)
		return -2
	error_pop_up = {"Title": "Invalid Action.", "Description": "One of the buildings you tried to destroy is unremovable (i.e. Industries)."}
	return -3
	
func _get_building_id_of_v2i(v2i:Vector2i):
	var get_array_location = built.find(v2i)
	if get_array_location == -1:
		return -1
	else:
		return built_data[get_array_location][1]
