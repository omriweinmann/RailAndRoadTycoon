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
		my_b_id = info[1]
		#print(sprite_override,",",sprite_override == "null")
		if sprite_override == "null":
			if info[1] == 0:
				get_tree().call_group("Building","_change_sprite",0)
			if info[1] == 1 or info[1] == 2:
				#print(Global.building_source[my_b_id][1] + Global.building_source[my_b_id][2])
				$Sprite2D.texture = _load(Global.building_source[my_b_id][1] + Global.building_source[my_b_id][2])
			if info[1] == 3:
				$Sprite2D.texture = _load(Global.building_source[my_b_id][1] + Global.building_source[my_b_id][2])
				get_tree().call_group("Building","_change_sprite",0)
		else:
			$Sprite2D.texture = _load(sprite_override)
func _destroy(map_location):
	if tilemap==map_location and Global.building_source[my_b_id][3] == true:
		if not Global.road_changers.find(my_b_id) == -1:
			get_tree().call_group("Building","_change_sprite",0)
		queue_free()
func _change_sprite(b_id):
	if not Global.road_changers.find(my_b_id) == -1 and not Global.road_changers.find(b_id) == -1:
		var check1 = "0"
		if not Global.road_changers.find(Global._get_building_id_of_v2i(tilemap+Vector2i(0,-1))) == -1:
			check1 = "1"
		var check2 = "0"
		if not Global.road_changers.find(Global._get_building_id_of_v2i(tilemap+Vector2i(-1,0))) == -1:
			check2 = "1"
		var check3 = "0"
		if not Global.road_changers.find(Global._get_building_id_of_v2i(tilemap+Vector2i(1,0))) == -1:
			check3 = "1"
		var check4 = "0"
		if not Global.road_changers.find(Global._get_building_id_of_v2i(tilemap+Vector2i(0,1))) == -1:
			check4 = "1"
		if my_b_id == 3:
			$LowerSprite.texture = _load(Global.building_source[0][1] + check1 + check2 + check3 + check4 + Global.building_source[0][2])
		else:
			$Sprite2D.texture = _load(Global.building_source[b_id][1] + check1 + check2 + check3 + check4 + Global.building_source[b_id][2])

func _load(sprite):
	var find = Global.sprite.find(sprite)
	if not find == -1:
		return Global.loaded_sprite[find]
	else:
		var load_sprite = load(sprite)
		Global.sprite.append(sprite)
		Global.loaded_sprite.append(load_sprite)
		return load_sprite
