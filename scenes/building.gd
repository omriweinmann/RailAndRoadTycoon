extends Area2D

var tilemap = Vector2i(-1,-1)

func _give_data(array_location,map_location,local):
	array_location = max(array_location,0)
	if tilemap == Vector2i(-1,-1) or tilemap==map_location:
		position = local
		tilemap = map_location
		#print(array_location,tilemap)
		var info = Global.built_data[array_location]
		$Sprite2D.texture = load(info[1])

func _destroy(map_location):
	if tilemap==map_location:
		queue_free()
