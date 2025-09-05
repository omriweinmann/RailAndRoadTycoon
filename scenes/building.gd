extends Area2D

var my_b_id = -1

var tilemap = Vector2i(-1,-1)

func _give_data(array_location,map_location,local):
	array_location = max(array_location,0)
	if (tilemap == Vector2i(-1,-1) or tilemap==map_location) and (my_b_id == -1 or my_b_id == Global.building_id_selected):
		position = local
		tilemap = map_location
		#print(array_location,tilemap)
		var info = Global.built_data[array_location]
		var string_nums = ""
		my_b_id = info[1]
		if info[1] == 0:
			get_tree().call_group("Building","_change_sprite",0)
		if info[1] == 1 or info[1] == 2:
			$Sprite2D.texture = load(Global.building_source[my_b_id][1] + Global.building_source[my_b_id][2])
func _destroy(map_location):
	if tilemap==map_location and Global.building_source[my_b_id][3] == true:
		if my_b_id == 0:
			get_tree().call_group("Building","_change_sprite",0)
		queue_free()
func _change_sprite(b_id):
	if my_b_id == b_id:
		var check1 = "0"
		if Global._get_building_id_of_v2i(tilemap+Vector2i(0,-1)) == 0:
			check1 = "1"
		var check2 = "0"
		if Global._get_building_id_of_v2i(tilemap+Vector2i(-1,0)) == 0:
			check2 = "1"
		var check3 = "0"
		if Global._get_building_id_of_v2i(tilemap+Vector2i(1,0)) == 0:
			check3 = "1"
		var check4 = "0"
		if Global._get_building_id_of_v2i(tilemap+Vector2i(0,1)) == 0:
			check4 = "1"
		$Sprite2D.texture = load(Global.building_source[b_id][1] + check1 + check2 + check3 + check4 + Global.building_source[b_id][2])
