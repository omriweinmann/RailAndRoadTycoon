extends Node2D

var width:int = Global.width
var height:int = Global.height
var altitude:float = Global.altitude

var seed:int = Global.seed

@export var max_zoom:float = 3
@export var min_zoom:float = 0

var debug:bool = Global.debug

var mouse_good = _load("res://asset/pictures/select/MouseLocation.png")
var mouse_destroy = _load("res://asset/pictures/select/Select1.png")
var mouse_bad = _load("res://asset/pictures/select/MouseLocationBad.png")

var done_loading = Global.done_loading

var selected = Vector2i(-1,-1)

var pan_og_location = Vector2(-1,-1)

var plc_og_location = Vector2i(-1,-1)

signal data_to_building(array_location)

var speed = 150
var zoom_speed = 0.2
var zoom_dir = 0.0

var drag_build_array = []
var drag_build_array2 = []

var rng = RandomNumberGenerator.new()

@export var atlas_height:int = 8
var atlas_heightfloor:int = atlas_height - 1
@export var texture_size_x = 64
@export var texture_size_y = 40

var load_label: PackedScene = _load("res://scenes/label.tscn")
var load_building: PackedScene = _load("res://scenes/building.tscn")
var load_vehicle: PackedScene = _load("res://scenes/vehicle.tscn")

var random = RandomNumberGenerator.new()
var cooldown = false

var viables = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.built = []
	Global.built_data = []
	Global.error_pop_up = {"Title": "Nil", "Description": "Nil"}
	Global.done_loading = false
	Global.money_base = 100000
	rng.seed = seed
	var vp_size = get_viewport().get_visible_rect().size
	$BG.position = Vector2(texture_size_x*width/2, 0)
	var zoom_start = vp_size[0] / (width*texture_size_x)
	$Camera2D.zoom = Vector2(zoom_start,zoom_start)
	if seed == -1:
		seed = random.randi()
		#print(seed)
	var noise = NoiseTexture2D.new()
	var fast_noise = FastNoiseLite.new()
	fast_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	fast_noise.frequency = 0.01
	fast_noise.seed = seed
	noise.width = width
	noise.height = height
	noise.noise = fast_noise
	$Noise.texture = noise
	$Noise.position =  Vector2(vp_size[0]*0.5,vp_size[1]*0.5)
	
	await noise.changed

	for y in height:
		for x in width:
			var real_x = width - x - 1
			if debug:
				var label = load_label.instantiate()
				$Labels.add_child(label)
			
			var noise_value = fast_noise.get_noise_2d(float(real_x),float(y))
			#print(noise_value)
			var noise_value_processed = min(atlas_heightfloor,max(0,int(min(atlas_heightfloor,max(0,floor(((noise_value+1)/2)*atlas_height)))+(atlas_heightfloor*altitude))))
			#print(noise_value_processed)
			var local = Vector2i(real_x,y)
			#print(local)
			$TileMapLayer.set_cell(local,1,Vector2i(0,noise_value_processed))
			
			get_tree().call_group('Label','_make_label', Vector2i(x,y), $TileMapLayer.map_to_local(Vector2i(x,y)))
			
			var offset = max(0,$TileMapLayer.get_cell_atlas_coords(local)[1]-2)*2
			Global.map_to_local[local] = [$TileMapLayer.map_to_local(local),_is_viable(local),offset]
			if _is_viable(local):
				viables.append(local)
	var industries = int((width/100) * float(Global.industries_per_100))
	if viables.size() > 0:
		var overriden = false
		for num in industries:
			await get_tree().create_timer(0.01, true, true).timeout
			var ran_num = rng.randi_range(0,viables.size()-1)
			#print(ran_num)
			if ran_num < 1:
				break
			var new_miot = viables[ran_num]
			var new_miot_local = $TileMapLayer.map_to_local(new_miot) - Vector2(0,max(0,$TileMapLayer.get_cell_atlas_coords(new_miot)[1]-2)*2)
			if _is_viable(new_miot) and viables.size() > 0:
				if overriden == false:
					Global.building_id_selected = Global.proc_buildings.pick_random()
				overriden = false
				var build_status = Global._build(new_miot, new_miot_local)
				var is_industry = Global.building_source[Global.building_id_selected][4]
				if not is_industry == []:
					var sd = is_industry[0]
					if not sd == 0:
						for x in sd:
							x -= int(sd/2)
							for y in sd:
								y -= int(sd/2)
								var vec = new_miot+Vector2i(x,y)
								var find_vec = viables.find(vec)
								if not find_vec == -1:
									viables.remove_at(find_vec)
					var ex = is_industry[1]
					if not ex == []:
						for x in ex[0]:
							var ran_sprite = is_industry[2].pick_random()
							#print(ran_sprite)
							var ran_x = rng.randi_range(-ex[1],ex[1])
							var ran_y = rng.randi_range(-ex[1],ex[1])
							var miot_ex = new_miot+Vector2i(ran_x,ran_y)
							var miot_local_ex = $TileMapLayer.map_to_local(miot_ex) - Vector2(0,max(0,$TileMapLayer.get_cell_atlas_coords(miot_ex)[1]-2)*2)
							var build_status_ex = Global._build(miot_ex, miot_local_ex)
							if build_status_ex == -1 and _is_viable(miot_ex):
								_building(build_status_ex, miot_ex, miot_local_ex, ran_sprite)
					var pollute = is_industry[3]
					if pollute:
						for x in 7:
							x -= 3
							for y in 7:
								y -= 3
								var vec = new_miot+Vector2i(x,y)
								var ran_check = rng.randi_range(0,2*(abs(x)))
								#print(ran_check)
								if not (vec.x < 0 or vec.x > width - 1 or vec.y < 0 or vec.y > (height - 1)) and ran_check  == 1:
									$TileMapLayer.set_cell(vec,2,$TileMapLayer.get_cell_atlas_coords(vec))
					var leads_to = is_industry[4]
					if not leads_to == -1:
						overriden = true
						Global.building_id_selected = leads_to
				if build_status == -1:
					_building(build_status, new_miot, new_miot_local, "null")
				elif build_status == -2:
					get_tree().call_group('Building','_destroy',new_miot)
				elif not build_status == -3:
					get_tree().call_group('Building','_give_data',build_status,new_miot,new_miot_local,"null")
			elif not viables.size() > 0:
				break
	Global.building_id_selected = -1
	done_loading = true
	$LoadingScreen.queue_free()

func _process(delta: float) -> void:
	$UI/FramesPS.text = str(round((1/delta)*10)/10)
	if done_loading == true:
		$UI.visible = true
		var vp_size = get_viewport().get_visible_rect().size
		var limit_left = 0
		var limit_right = width * texture_size_x
		var cam_height = height * texture_size_y
		var limit_top = cam_height / -2
		var limit_bottom = cam_height / 2
		if Input.is_action_just_released("CamZoomIn"):
			zoom_dir += 1.0
		if Input.is_action_just_released("CamZoomOut"):
			zoom_dir -= 1.0
		if Input.is_action_just_pressed("Pan"):
			pan_og_location = get_local_mouse_position()
		var pan_addition = Vector2(0,0)
		if Input.is_action_pressed("Pan"):
			pan_addition = (pan_og_location - get_global_mouse_position())
		#print(vp_size[1],", ",$Camera2D.limit_bottom*min_zoom)
		#print((width*texture_size_x)*$Camera2D.zoom[0], (height*texture_size_y)*$Camera2D.zoom[1])
		#print(min_zoom,", ",max_zoom)
		#if vp_size[0] < $Camera2D.limit_right*min_zoom and vp_size[1] < $Camera2D.limit_bottom*min_zoom:
			#min_zoom -= 0.025
			#min_zoom = max(0.2, min_zoom)
			#var zoom = $Camera2D.zoom
			#$Camera2D.zoom = Vector2(max(min_zoom,min(max_zoom,zoom.x)),max(min_zoom,min(max_zoom,zoom.y)))
		#if vp_size[0] > $Camera2D.limit_right*min_zoom or vp_size[1] > $Camera2D.limit_bottom*min_zoom:
			#min_zoom += 0.025
			#var zoom = $Camera2D.zoom
			#$Camera2D.zoom = Vector2(max(min_zoom,min(max_zoom,zoom.x)),max(min_zoom,min(max_zoom,zoom.y)))
		if cooldown == false and Global.mouse_in_menu == false:
			cooldown = true
			#print(zoom_dir)
			var pre_pos = $BG.position + pan_addition
			#print(limit_left,", ",limit_right,"/ ",limit_top,", ",limit_bottom)
			var bg_pos_x = min(limit_right, max(limit_left, pre_pos[0]))
			var bg_pos_y = min(limit_bottom, max(limit_top, pre_pos[1]))
			var zoom_amount = zoom_dir * zoom_speed * $Camera2D.zoom[0]
			zoom_dir = 0.0
			var zoom = max(min_zoom+0.025,min(max_zoom,$Camera2D.zoom[0] + zoom_amount))
			
			var zoom_pos_change = ($BG.position - get_global_mouse_position()) * ($Camera2D.zoom[0]-zoom)/$Camera2D.zoom[0]
			$Camera2D.zoom = Vector2(zoom,zoom)
			#print(zoom_pos_change)
			$BG.position = Vector2(bg_pos_x, bg_pos_y) + zoom_pos_change
			$Camera2D.position = $BG.position
			#print($Camera2D.zoom, max_zoom, min_zoom+0.025)
			$BG.scale = Vector2((vp_size[0] / 128)/$Camera2D.zoom[0], (vp_size[1] / 128)/$Camera2D.zoom[0])
		elif cooldown == false:
			zoom_dir = 0.0
		if Input.is_action_just_pressed("Restart"):
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		#print(get_local_mouse_position())
		var mouse_is_on_tile = $TileMapLayer.local_to_map(get_local_mouse_position())
		#print(mouse_is_on_tile)
		var offset = max(0,$TileMapLayer.get_cell_atlas_coords(mouse_is_on_tile)[1]-2)*2
		var offset_s = max(0,$TileMapLayer.get_cell_atlas_coords(selected)[1]-2)*2
		var miot_local = $TileMapLayer.map_to_local(mouse_is_on_tile)-Vector2(0,offset)
		if mouse_is_on_tile.x < 0 or mouse_is_on_tile.x > width - 1 or mouse_is_on_tile.y < 0 or mouse_is_on_tile.y > (height - 1) or Global.building_id_selected == -1:
			$MouseLocationLocal.visible = false
		else:
			$MouseLocationLocal.visible = true
			if Global.building_id_selected == -2:
				$MouseLocationLocal/Sprite2D.texture = mouse_destroy
			else:
				if _is_viable(mouse_is_on_tile):
					$MouseLocationLocal/Sprite2D.texture = mouse_good
				else:
					$MouseLocationLocal/Sprite2D.texture = mouse_bad
		var find = Global.built.find(mouse_is_on_tile)
		if Input.is_action_just_pressed("LeftClick") and Global.mouse_in_menu == false:
			plc_og_location = mouse_is_on_tile
		if Input.is_action_just_released("LeftClick") and Global.mouse_in_menu == false:
			#print(Global.building_id_selected)
			if Global.building_id_selected == 0:
				var info_array = _drag_line_build(mouse_is_on_tile)
				if info_array:
					for x in abs(info_array[0])+1:
						if info_array[1] == false:
							x = -x
						var offset_drag = Vector2i(0,x)
						if info_array[2] == false:
							offset_drag = Vector2i(x,0)
						var new_miot = plc_og_location - offset_drag
						var new_miot_local = $TileMapLayer.map_to_local(new_miot) - Vector2(0,max(0,$TileMapLayer.get_cell_atlas_coords(new_miot)[1]-2)*2)
						if _is_viable(new_miot):
							var build_status = Global._build(new_miot, new_miot_local)
							if build_status == -1:
								_building(build_status, new_miot, new_miot_local,"null")
							elif build_status == -2:
								get_tree().call_group('Building','_destroy',new_miot)
							elif not build_status == -3:
								get_tree().call_group('Building','_give_data',build_status,new_miot,new_miot_local,"null")
			elif Global.building_id_selected == -2:
				var change = mouse_is_on_tile - plc_og_location
				var x_neg = false
				if not change.x == abs(change.x):
					x_neg = true
				var y_neg = false
				if not change.y == abs(change.y):
					y_neg = true
				for x in min(35,abs(change.x)+1):
					for y in min(35,abs(change.y)+1):
						var real_x = x
						if x_neg == true:
							real_x = -x
						if y_neg == true:
							y = -y
						#print(Vector2i(x,y))
						var new_miot = plc_og_location + Vector2i(real_x,y)
						#print(new_miot)
						var new_miot_local = $TileMapLayer.map_to_local(new_miot)
						if _is_viable(new_miot):
							var build_status = Global._build(new_miot, new_miot_local)
							if build_status == -1:
								_building(build_status, new_miot, new_miot_local,"null")
							elif build_status == -2:
								get_tree().call_group('Building','_destroy',new_miot)
							elif not build_status == -3:
								get_tree().call_group('Building','_give_data',build_status,new_miot,new_miot_local,"null")
				#print(x)
			#print(change)
			#if $MouseLocationLocal.visible == true:
				#selected = Vector2i(mouse_is_on_tile)
			#else:
				#selected = Vector2i(-1, -1)
			else: #Global.building_id_selected == 1 or Global.building_id_selected == 2:
				var new_miot = mouse_is_on_tile
				var new_miot_local = miot_local
				if _is_viable(new_miot):
					var build_status = Global._build(new_miot, new_miot_local)
					if build_status == -1:
						_building(build_status, new_miot, new_miot_local,"null")
					elif build_status == -2:
						get_tree().call_group('Building','_destroy',new_miot)
					elif not build_status == -3:
						get_tree().call_group('Building','_give_data',build_status,new_miot,new_miot_local,"null")
			#print(Global.built.find(selected))
		if Input.is_action_just_released("RightClick") and Global.mouse_in_menu == false:
			Global.building_id_selected = -1
			#print(Global.built)
		if Input.is_action_just_released("Q"):
			Global.building_id_selected = -2
		if Input.is_action_just_released("W"):
			Global.building_id_selected = 0
		#print(Global.built)

		#if not selected == Vector2i(-1, -1):
			#$SelectLocation.position = $TileMapLayer.map_to_local(selected)-Vector2(0,offset_s)
			#$SelectLocation.visible = true
		#else:
			#$SelectLocation.visible = false
		#print(offset)
		#print(selected)

		if Global.mouse_in_menu == false and (not Input.is_action_pressed("LeftClick") or Global.building_id_selected == 1):
			$MouseLocationLocal.position = miot_local
			for node in $NewMouses.get_children():
				node.queue_free()
			drag_build_array = []
			drag_build_array2 = []
		elif Global.mouse_in_menu == false:
			if Global.building_id_selected == 0:
				for node in $NewMouses.get_children():
					node.queue_free()
				drag_build_array = []
				drag_build_array2 = []
				var info_array = _drag_line_build(mouse_is_on_tile)
				if info_array:
					for x in abs(info_array[0])+1:
						if info_array[1] == false:
							x = -x
						var offset_drag = Vector2i(0,x)
						if info_array[2] == false:
							offset_drag = Vector2i(x,0)
						var new_miot = plc_og_location - offset_drag
						var new_miot_local = $TileMapLayer.map_to_local(new_miot)
						if new_miot.x < 0 or new_miot.x > width - 1 or new_miot.y < 0 or new_miot.y > (height - 1) or Global.building_id_selected == -1:
							$MouseLocationLocal.visible = false
						else:
							$MouseLocationLocal.visible = true
							if _is_viable(new_miot):
								$MouseLocationLocal/Sprite2D.texture = mouse_good
							else:
								$MouseLocationLocal/Sprite2D.texture = mouse_bad
						var new_mouse = $MouseLocationLocal.duplicate()
						$NewMouses.add_child(new_mouse)
						new_mouse.position = new_miot_local - Vector2(0,max(0,$TileMapLayer.get_cell_atlas_coords(new_miot)[1]-2)*2)
			if Global.building_id_selected == -2:
				var change = mouse_is_on_tile - plc_og_location
				var x_neg = false
				if not change.x == abs(change.x):
					x_neg = true
				var y_neg = false
				if not change.y == abs(change.y):
					y_neg = true
				var check_array = []
				for x in min(35,abs(change.x)+1):
					for y in min(35,abs(change.y)+1):
						var real_x = x
						if x_neg == true:
							real_x = -x
						if y_neg == true:
							y = -y
						#print(Vector2i(x,y))
						var new_miot = plc_og_location + Vector2i(real_x,y)
						#print(new_miot)
						var new_miot_local = $TileMapLayer.map_to_local(new_miot)
						var to_be_named = str(new_miot.x) + "_" + str(new_miot.y)
						#print(to_be_named)
						check_array.append(to_be_named)
						if drag_build_array.find(to_be_named) == -1:
							if new_miot.x < 0 or new_miot.x > width - 1 or new_miot.y < 0 or new_miot.y > (height - 1) or Global.building_id_selected == -1:
								$MouseLocationLocal.visible = false
							else:
								$MouseLocationLocal.visible = true
								$MouseLocationLocal/Sprite2D.texture = mouse_destroy
							var new_mouse = $MouseLocationLocal.duplicate()
							$NewMouses.add_child(new_mouse)
							drag_build_array.append(to_be_named)
							drag_build_array2.append(new_mouse)
							new_mouse.position = new_miot_local - Vector2(0,max(0,$TileMapLayer.get_cell_atlas_coords(new_miot)[1]-2)*2)
				for x in drag_build_array:
					var find_in_check = check_array.find(x)
					if find_in_check == -1:
						var find_in_dba = drag_build_array.find(x)
						drag_build_array.remove_at(find_in_dba)
						drag_build_array2[find_in_dba].queue_free()
						drag_build_array2.remove_at(find_in_dba)
			$MouseLocationLocal.visible = false
		else:
			for node in $NewMouses.get_children():
				node.queue_free()
			drag_build_array = []
			drag_build_array2 = []

func _is_viable(map_location):
	if (map_location.x >= 0 or map_location.x <= width - 1 or map_location.y >= 0 or map_location.y <= (height - 1)) and $TileMapLayer.get_cell_atlas_coords(map_location).y > 1:
		return true
	else:
		return false

func _building(array_location, map_location, local, sprite_override):
	var building = load_building.instantiate()
	$Buildings.add_child(building)
	building.z_index = Global.building_source[Global.building_id_selected][5]
	get_tree().call_group('Building','_give_data',array_location,map_location,local,sprite_override)

func _on_input_cooldown_timeout() -> void:
	cooldown = false
	
func _drag_line_build(mouse_is_on_tile):
	if not plc_og_location == Vector2i(-1,-1):
		var change = mouse_is_on_tile - plc_og_location
		var var_to_use = change.y
		var y_question = true
		if abs(change.x) > abs(change.y):
			var_to_use = change.x
			y_question = false
		var negative = true
		if abs(var_to_use) == var_to_use:
			negative = false
		return [var_to_use,negative,y_question]
		
func _load(sprite):
	var find = Global.sprite.find(sprite)
	if not find == -1:
		return Global.loaded_sprite[find]
	else:
		var load_sprite = load(sprite)
		Global.sprite.append(sprite)
		Global.loaded_sprite.append(load_sprite)
		return load_sprite

func _vehicle(v_info):
	#print("please")
	var vehicle = load_vehicle.instantiate()
	$Buildings.add_child(vehicle)
	get_tree().call_group('Vehicle','_give_data',v_info)
	
