extends Node

var debug = false

var width:int = 250
var height:int = 250
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
		1,
		3,
	]
]

func _build(coords:Vector2i,_coords_local):
	if not building_id_selected == -1:
		var find = built.find(coords)
		#print(find,",",coords)
		if building_id_selected == -2 and not find == -1:
			_remove(find)
			return -2
		else:
			var get_from_source = building_source[building_id_selected]
			if find == -1:
				built.push_front(coords)
				built_data.push_front(
					[
						get_from_source[0],
						get_from_source[1] + str(get_from_source[3]) + get_from_source[2],
						get_from_source[3]
					]
				)
			else:
				var new_orient = built_data[find][2]+1
				if new_orient > get_from_source[4]:
					new_orient = get_from_source[3]
				built_data[find] = [
					get_from_source[0],
					get_from_source[1] + str(new_orient) + get_from_source[2],
					new_orient
				]
				#print(built_data[find])
			#print(get_from_source[3])
			#print(built,built_data)
			return find
	
func _remove(array_location):
	built.remove_at(array_location)
	built_data.remove_at(array_location)
	return true
