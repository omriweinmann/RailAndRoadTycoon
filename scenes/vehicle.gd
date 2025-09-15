extends Area2D

var my_v_id = ""
# Name
var my_warehouse = Vector2i(-1,-1)

var my_v_source = ""

var my_position

func _load(sprite):
	var find = Global.sprite.find(sprite)
	if not find == -1:
		return Global.loaded_sprite[find]
	else:
		var load_sprite = load(sprite)
		Global.sprite.append(sprite)
		Global.loaded_sprite.append(load_sprite)
		return load_sprite

func _give_data(v_info):
	#print(v_info)
	var get_warehouse = v_info[0]
	var get_v_id = v_info[1]
	var get_v_source = v_info[2]
	if my_warehouse == Vector2i(-1,-1) and my_v_id == "":
		my_warehouse = get_warehouse
		my_v_id = get_v_id
		my_v_source = get_v_source
		my_position = get_warehouse
		position = Global.map_to_local[get_warehouse][0]
		$Sprite2D.texture = _load("res://asset/pictures/vehicles/IndustrialGoodsTruck0001.png")
		_move(Vector2i(0,0))
		
func _move(end_goal) -> void:
	var path:Array = _scary_pathfinding(my_position,end_goal)
	#print(path)
	if path == []:
		Global.error_pop_up = {"Title": "Invalid Path.", "Description": my_v_id + " cannot find a valid path."}
		return #failed
	var before_offset = Vector2(-1,-1)
	var before_x = Vector2i(-1,-1)
	for x in path:
		var add = "0000"
		var offset = Vector2(-16,-10)
		print(x - my_position)
		if x - my_position == Vector2i(-1,0):
			add = "0100"
			offset = Vector2(-8,-5)
		if x - my_position == Vector2i(0,-1):
			add = "1000"
			offset = Vector2(8,-5)
		if x - my_position == Vector2i(1,0):
			add = "0010"
			offset = Vector2(8,5)
		if x - my_position == Vector2i(0,1):
			add = "0001"
			offset = Vector2(-8,5)
		if not before_offset == Vector2(-1,-1) and not before_x == Vector2i(-1,-1):
			if not before_offset == offset:
				var tween2 = create_tween()
				#print(Global.map_to_local[x])
				tween2.tween_property($".", "position", Global.map_to_local[before_x][0]+offset, 1.0)
				await get_tree().create_timer(0.5, true, true).timeout
				$Sprite2D.texture = _load(_get_source()[2] + add + _get_source()[3])
				await tween2.finished 
		#print(_get_source()[2] + add + _get_source()[3])
		$Sprite2D.texture = _load(_get_source()[2] + add + _get_source()[3])
		var tween = create_tween()
		#print(Global.map_to_local[x])
		tween.tween_property($".", "position", Global.map_to_local[x][0]+offset, 1.0)
		#print(tween.is_running())
		tween.play()
		#print(tween.is_running())
		await tween.finished
		my_position = x
		#print("done")
		before_offset = offset
		before_x = x
		
func _get_source():
	return Global.vehicle_shop[my_v_source]

func _get_warehouse_vehicle():
	for ve in Global.warehouses[my_warehouse][1]:
		if ve[0] == my_v_source:
			return ve
	return []
	
func _scary_pathfinding(start_miot:Vector2i, end_miot:Vector2i):
	#await get_tree().create_timer(10, true, true).timeout
	var open = {
		Vector2i(-10,-10): [
			Vector2i(-1,-1), 
			(Vector2i(-10,-10) - end_miot).length()+(Vector2i(-10,-10) - start_miot).length(),
			(Vector2i(-10,-10) - start_miot).length()
		],
		start_miot: [
			Vector2i(-1,-1), 
			(start_miot - end_miot).length(),
			0.0
		]
	}
	var closed = {}
	while true:
		var current = Vector2i(-10,-10)
		var current_f_cost = 99999999
		#print(current)
		#print("open: ",open)
		for o in open:
			var open_o = open[o]
			#print(open_o[1],",",current_f_cost)
			if open_o[1] < current_f_cost:
				current = o
				current_f_cost = open_o[1]
				
		if current == Vector2i(-10,-10):
			#print(closed)
			break #failsafe
		
		closed.get_or_add(current)
		closed[current] = open[current]
		open.erase(current)
		
		if current == end_miot:
			#print(closed)
			var path = []
			var current_path = end_miot
			while true:
				path.push_front(current_path)
				if current_path == start_miot:
					break
				current_path = closed[current_path][0]
				#print(current_path,", ",current_path == start_miot)
				
			return path
		
		var neighbors = [current+Vector2i(0,1),current+Vector2i(1,0),current+Vector2i(0,-1),current+Vector2i(-1,0)]
		for neighbor:Vector2i in neighbors:
			#print(Global.map_to_local.get(neighbor,[]))
			if not Global.map_to_local.get(neighbor,[]) == []: #check if its on the map
				#print("1")
				#print(Global._get_building_info_of_v2i(neighbor),"uyg")
				if Global.map_to_local[neighbor][1] and closed.get(neighbor,[]) == [] and (not Global._get_building_info_of_v2i(neighbor) == [] and not Global.road_changers.find(Global._get_building_info_of_v2i(neighbor)[1]) == -1): #check if its viable and if its not closed
					#print("2")
					if (not open.get(neighbor,[]) == [] and closed[current][2] + (current-neighbor).length() < open.get(neighbor,[])[2]) or open.get(neighbor,[]) == []:
						#print("3")
						var g_o_a = open.get_or_add(neighbor,[])
						#print(g_o_a)
						#print(open[neighbor])
						open[neighbor].append(current)
						var g_cost = closed[current][2] + (current-neighbor).length()
						open[neighbor].append(g_cost + (neighbor - end_miot).length())
						open[neighbor].append(g_cost)
					
	return []#failed
	#print(current)
	
func _process(_delta: float) -> void:
	$Sprite2D.position = Vector2(0,-Global.map_to_local[my_position][2])
