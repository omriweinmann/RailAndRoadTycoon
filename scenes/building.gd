extends Area2D

var my_b_id = -1

var tilemap = Vector2i(-1,-1)

func _give_data(array_location,map_location,local,sprite_override):
	array_location = max(array_location,0)
	if (tilemap == Vector2i(-1,-1) or tilemap==map_location) and (my_b_id == -1 or my_b_id == Global.building_id_selected):
		position = local
		tilemap = map_location
		#print(array_location,tilemap)
		var info = Global.built_data[array_location]
		var string_nums = ""
		#print(info[1])
		my_b_id = info[1]
		#print(sprite_override,",",sprite_override == "null")
		if sprite_override == "null":
			if info[1] == 0:
				get_tree().call_group("Building","_change_sprite",0)
			elif info[1] == 3:
				$Sprite2D.texture = _load(Global.building_source[my_b_id][1] + Global.building_source[my_b_id][2])
				get_tree().call_group("Building","_change_sprite",3)
			elif info[1] == 4:
				$Sprite2D.texture = _load(Global.building_source[my_b_id][1] + str(Global.orientation_selected) + Global.building_source[my_b_id][2])
				get_tree().call_group("Building","_change_sprite",4)
			else:
				#print(Global.building_source[my_b_id][1] + Global.building_source[my_b_id][2])
				$Sprite2D.texture = _load(Global.building_source[my_b_id][1] + Global.building_source[my_b_id][2])
		else:
			$Sprite2D.texture = _load(sprite_override)
func _destroy(map_location):
	if tilemap==map_location and Global.building_source[my_b_id][3] == true:
		if not Global.road_changers.find(my_b_id) == -1:
			get_tree().call_group("Building","_change_sprite",0)
		queue_free()
func _change_sprite(b_id):
	#print(b_id, my_b_id)
	if not Global.road_changers.find(my_b_id) == -1 and (not Global.road_changers.find(b_id) == -1 or b_id == 4):
		var check1 = _road_check(my_b_id,b_id,0,-1)
		var check2 = _road_check(my_b_id,b_id,-1,0)
		var check3 = _road_check(my_b_id,b_id,1,0)
		var check4 = _road_check(my_b_id,b_id,0,1)
		
		if my_b_id == 3:
			$LowerSprite.texture = _load(Global.building_source[0][1] + check1 + check2 + check3 + check4 + Global.building_source[0][2])
		else:
			$Sprite2D.texture = _load(Global.building_source[my_b_id][1] + check1 + check2 + check3 + check4 + Global.building_source[my_b_id][2])
				
func _road_check(mbi, bi, x, y):
	var array_info = Global._get_building_info_of_v2i(tilemap+Vector2i(x, y))

	if not array_info == []:
		if array_info[1] == 4:
			print(array_info[2],": ",x,",",y)
			if array_info[2] == 0 and y == 0:
				return "1"
			elif array_info[2] == 1 and x == 0:
				return "1"
		else:
			if not Global.road_changers.find(array_info[1]) == -1:
					return "1"
	return "0"

func _load(sprite):
	var find = Global.sprite.find(sprite)
	if not find == -1:
		return Global.loaded_sprite[find]
	else:
		var load_sprite = load(sprite)
		Global.sprite.append(sprite)
		Global.loaded_sprite.append(load_sprite)
		return load_sprite
