extends Node

var debug = false

var width:int = 125
var height:int = 125
var altitude:float = 0

var mouse_in_menu = false

var seed:int = -1

var built:Array = []
var built_data:Array = []

var building_id_selected = -1

var building_source = [
	[
		"Road",
		"res://asset/pictures/buildings/RoadOrientation",
		".png",
	],
	[
		"Factory",
		"res://asset/pictures/buildings/Factory",
		".png",
	]
]

func _build(coords:Vector2i,_coords_local):
	if not building_id_selected == -1:
		var find = built.find(coords)
		#print(find,",",coords)
		if building_id_selected == -2 and not find == -1:
			_remove(find)
			return -2
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
	built.remove_at(array_location)
	built_data.remove_at(array_location)
	return true
	
func _get_building_id_of_v2i(v2i:Vector2i):
	var get_array_location = built.find(v2i)
	if get_array_location == -1:
		return -1
	else:
		return built_data[get_array_location][1]
