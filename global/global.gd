extends Node

var debug = false

var width:int = 125
var height:int = 125
var altitude:float = 0

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
		"res://asset/pictures/buildings/RoadOrientation", # File Location
		".png", # File Format
		true, # Removable (for example, industries are unremovable)
		0, # Social Distancing (if procedurally generated, how many blocks away should industries not spawn?)
	],
	[
		"Factory",
		"res://asset/pictures/buildings/Factory",
		".png",
		false,
		75,  
	],
	[
		"Coal Mine",
		"res://asset/pictures/buildings/CoalMine",
		".png",
		false,
		50,  
	]
]

var proc_buildings = [1,2]

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
