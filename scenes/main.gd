extends Node2D

var width:int = Global.width
var height:int = Global.height
var altitude:float = Global.altitude

var seed:int = Global.seed

@export var max_zoom:float = 9999
@export var min_zoom:float = 0

@export var debug:bool = false

var speed = 150
var zoom_speed = 0.05

@export var atlas_height:int = 8
var atlas_heightfloor:int = atlas_height - 1
@export var texture_size_x = 64
@export var texture_size_y = 40

var load_label: PackedScene = load("res://scenes/label.tscn")

var random = RandomNumberGenerator.new()
var cooldown = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BG.position = Vector2(texture_size_x*width/2, 0)
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
	var vp_size = get_viewport().get_visible_rect().size
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
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var vp_size = get_viewport().get_visible_rect().size
	var limit_left = 0
	var limit_right = width * texture_size_x
	var cam_height = height * texture_size_y
	var limit_top = cam_height / -2
	var limit_bottom = cam_height / 2
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
	if cooldown == false:
		cooldown = true
		var direction = Input.get_vector("CamLeft", "CamRight", "CamUp", "CamDown")
		var zoom_dir = Input.get_axis("CamZoomOut","CamZoomIn")
		var pre_pos = $BG.position + (direction * speed / $Camera2D.zoom[0] / 2)
		#print(limit_left,", ",limit_right,"/ ",limit_top,", ",limit_bottom)
		var bg_pos_x = min(limit_right, max(limit_left, pre_pos[0]))
		var bg_pos_y = min(limit_bottom, max(limit_top, pre_pos[1]))
		$BG.position = Vector2(bg_pos_x, bg_pos_y)
		$Camera2D.position = $BG.position
		var zoom_amount = zoom_dir * zoom_speed * $Camera2D.zoom[0]
		var zoom = $Camera2D.zoom + Vector2(zoom_amount,zoom_amount)
		$Camera2D.zoom = Vector2(max(min_zoom+0.025,min(max_zoom,zoom.x)),max(min_zoom+0.025,min(max_zoom,zoom.y)))
		#print($Camera2D.zoom, max_zoom, min_zoom+0.025)
		$BG.scale = Vector2((vp_size[0] / 128)/$Camera2D.zoom[0], (vp_size[1] / 128)/$Camera2D.zoom[0])
	if Input.is_action_just_pressed("Restart"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	#print(get_local_mouse_position())
	var mouse_is_on_tile = $TileMapLayer.local_to_map(get_local_mouse_position())
	print(mouse_is_on_tile)
	if mouse_is_on_tile.x < 0 or mouse_is_on_tile.x > width - 1 or mouse_is_on_tile.y < 0 or mouse_is_on_tile.y > (height - 1):
		$MouseLocationLocal.visible = false
	else:
		$MouseLocationLocal.visible = true
	var offset = max(0,$TileMapLayer.get_cell_atlas_coords(mouse_is_on_tile)[1]-2)*2
	#print(offset)
	$MouseLocationLocal.position = $TileMapLayer.map_to_local(mouse_is_on_tile)-Vector2(0,offset)


func _on_input_cooldown_timeout() -> void:
	cooldown = false
