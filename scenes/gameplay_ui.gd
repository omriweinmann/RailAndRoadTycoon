extends Control

func _ready() -> void:
	$Top/MenuBar/Automobile.add_item("Road")
	$Top/MenuBar/Automobile.add_item("Warehouse")
	$Top/MenuBar/Automobile.add_separator("Trucks")
	$Top/MenuBar/Automobile.add_submenu_item("Truck Station", "TruckStation")
	$Top/MenuBar/Automobile/TruckStation.add_item("/")
	$Top/MenuBar/Automobile/TruckStation.add_item("\\")
	
func _on_mouse_entered() -> void:
	Global.mouse_in_menu = false
	#print(false)

func _on_mouse_exited() -> void:
	Global.mouse_in_menu = true
	#print(true)
	
func _process(delta: float) -> void:
	if Global.building_id_selected == -2:
		$Top/Destroy.button_pressed = true
	else:
		$Top/Destroy.button_pressed = false
	#pass

func _on_destroy_toggled(toggled_on: bool) -> void:
	#print(toggled_on == true)
	if toggled_on == true:
		Global.building_id_selected = -2
	elif Global.building_id_selected == -2:
		Global.building_id_selected = -1
	#print(Global.building_id_selected)
	
func _on_automobile_id_pressed(id: int) -> void:
	var text = $Top/MenuBar/Automobile.get_item_text(id)
	for building_source in Global.building_source:
		if building_source[0] == text:
			Global.building_id_selected = Global.building_source.find(building_source)
			print(Global.building_id_selected)
			break

func _on_debug_id_pressed(id: int) -> void:
	var text = $Top/MenuBar/Debug.get_item_text(id)
	for building_source in Global.building_source:
		if building_source[0] == text:
			Global.building_id_selected = Global.building_source.find(building_source)
			print(Global.building_id_selected)
			break

func _on_truck_station_id_pressed(id: int) -> void:
	Global.orientation_selected = id
	Global.building_id_selected = 4
