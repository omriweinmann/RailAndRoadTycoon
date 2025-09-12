extends Control

var route_selected:int = 0
var load_type_selected:int = 0
var warehouse_selected := Vector2i(0,0)

var selected_vehicle = "Nothing"
var vehicle_id_selected = 0

func _ready() -> void:
	_load_automobile()
	_load_route_options()
	_load_route(route_selected)
	for chi in Global.vehicle_shop:
		print(chi)
		$Warehouse/Top/MarginContainer3/HBoxContainer/Vehicle.add_item(chi)
func _load_automobile() -> void:
	$Top/MenuBar/Automobile.add_item("Road")
	$Top/MenuBar/Automobile.add_item("Warehouse")
	$Top/MenuBar/Automobile.add_separator("Trucks")
	$Top/MenuBar/Automobile.add_submenu_item("Truck Station", "TruckStation")
	$Top/MenuBar/Automobile/TruckStation.add_item("/")
	$Top/MenuBar/Automobile/TruckStation.add_item("\\")
	
func _load_route_options() -> void:
	$Routing/Top/MarginContainer2/HBoxContainer/Options.add_item("No action")
	$Routing/Top/MarginContainer2/HBoxContainer/Options.add_item("Wait for load")
	$Routing/Top/MarginContainer2/HBoxContainer/Options.add_item("Load available")
	$Routing/Top/MarginContainer2/HBoxContainer/Options.add_item("Unload")
	$Routing/Top/MarginContainer2/HBoxContainer/Options.add_item("Load and Unload")
	$Routing/Top/MarginContainer2/HBoxContainer/Options.select(0)
	
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
	if Global.building_id_selected == -4:
		$Top/Route.button_pressed = true
		$Routing.visible = true
	else:
		$Top/Route.button_pressed = false
		$Routing.visible = false
	if Global.building_id_selected == -2:
		$Top/Destroy.button_pressed = true
	else:
		$Top/Destroy.button_pressed = false
	if Global.building_id_selected == -4:
		$Top/Route.button_pressed = true
		$Routing.visible = true
	else:
		$Top/Route.button_pressed = false
		$Routing.visible = false
	if Global.building_id_selected == -5:
		$Top/Warehouses.button_pressed = true
		$Warehouse.visible = true
	else:
		$Top/Warehouses.button_pressed = false
		$Warehouse.visible = false
	if Global.money_conversions[Global.conversion_selected][3] == false:
		$Money.text = Global.money_conversions[Global.conversion_selected][1] + " " + str(Global.money_base*Global.money_conversions[Global.conversion_selected][2])
	else:
		$Money.text = str(Global.money_base*Global.money_conversions[Global.conversion_selected][2]) + " " + Global.money_conversions[Global.conversion_selected][1]
	#pass
	
func _on_route_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		Global.building_id_selected = -4
	elif Global.building_id_selected == -4:
		Global.building_id_selected = -1
	
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
	
func _add_to_route(miot):
	var find = Global.truck_stations.get(miot,[])
	if not find == []:
		var array = Global.routes.get_or_add(route_selected)
		array.append([miot,load_type_selected])
		_load_route(route_selected)
	else:
		Global.error_pop_up = {"Title": "Invalid Action.", "Description": "Only stations can be added to routes."}
func _on_route_id_value_changed(value: float) -> void:
	route_selected = int(value)
	_load_route(route_selected)
	
func _load_route(value):
	var key = Global.routes.get_or_add(value, [])
	Global.routes[value] = key
	for child in $Routing/Panel/MarginContainer/Bottom/VBoxContainer.get_children():
		child.queue_free()
	for test in key:
		var label = Label.new()
		label.text = Global.truck_stations.get(test[0])[1] + " (" + $Routing/Top/MarginContainer2/HBoxContainer/Options.get_item_text(test[1]) + ")"
		$Routing/Panel/MarginContainer/Bottom/VBoxContainer.add_child(label)
	var final_label = Label.new()
	final_label.text = "---End of Route---"
	$Routing/Panel/MarginContainer/Bottom/VBoxContainer.add_child(final_label)

func _on_route_options_item_selected(index: int) -> void:
	load_type_selected = index


func _on_route_delete_pressed() -> void:
	var array:Array = Global.routes[route_selected]
	if array.size() > 0:
		array.remove_at(array.size()-1)
		_load_route(route_selected)


func _on_money_pressed() -> void:
	Global.conversion_selected += 1
	if Global.conversion_selected > Global.money_conversions.size()-1:
		Global.conversion_selected = 0


func _on_warehouses_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		Global.building_id_selected = -5
	elif Global.building_id_selected == -5:
		Global.building_id_selected = -1
		
func _select_warehouse(miot):
	var find = Global.warehouses.get(miot,[])
	if not find == []:
		warehouse_selected = miot
		$Warehouse/Top/MarginContainer/Title.text = "Selected: " + find[0] + str(miot)
		_load_warehouse_vehicles(warehouse_selected)
	else:
		Global.error_pop_up = {"Title": "Invalid Action.", "Description": "Only warehouses can be selected."}
	

func _on_vehicle_item_selected(index: int) -> void:
	selected_vehicle = $Warehouse/Top/MarginContainer3/HBoxContainer/Vehicle.get_item_text(index)
	_load_warehouse_vehicles(warehouse_selected)
	#print(selected_vehicle)


func _on_buy_pressed() -> void:
	if not selected_vehicle == "Nothing":
		if Global.money_base >= Global.vehicle_shop[selected_vehicle][0]:
			Global.money_base -= Global.vehicle_shop[selected_vehicle][0]
			var warehouse:Array = Global.warehouses[warehouse_selected]
			Global.vehicles_n_i += 1
			warehouse[1].push_back([selected_vehicle,selected_vehicle+" #"+str(Global.vehicles_n_i)])
			_load_warehouse_vehicles(warehouse_selected)
			_on_vehicle_id_value_changed(warehouse[1].size())
	
func _load_warehouse_vehicles(warehouse):
	vehicle_id_selected = 1
	for child in $Warehouse/Panel/MarginContainer/Bottom/VBoxContainer.get_children():
		child.queue_free()
	if Global.warehouses[warehouse][1] == []:
		var label = Label.new()
		label.text = "---No Vehicles Assigned---"
		$Warehouse/Panel/MarginContainer/Bottom/VBoxContainer.add_child(label)
	else:
		var x = 0
		for child in Global.warehouses[warehouse][1]:
			x += 1
			var label = Label.new()
			label.text = child[1]
			if x == vehicle_id_selected:
				label.add_theme_color_override("font_color", Color(1, 0.5, 0))
			$Warehouse/Panel/MarginContainer/Bottom/VBoxContainer.add_child(label)
		


func _on_vehicle_id_value_changed(value: float) -> void:
	#print(value)
	$Warehouse/Top/MarginContainer2/HBoxContainer/VehicleID.min_value = 1.0
	$Warehouse/Top/MarginContainer2/HBoxContainer/VehicleID.max_value = Global.warehouses[warehouse_selected][1].size()
	vehicle_id_selected = int(value)
	_load_warehouse_vehicles(warehouse_selected)
