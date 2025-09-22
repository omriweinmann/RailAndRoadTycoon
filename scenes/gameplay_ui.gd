extends Control

var route_selected:int = 1
var load_type_selected:int = 0
var warehouse_selected := Vector2i(-1,-1)

var selected_vehicle = "Nothing"
var vehicle_id_selected = 0

var before_money = Global.money_base
var money_change = 0
var seconds = 2.0

func _ready() -> void:
	Global._day_tick()
	_load_automobile()
	_load_route_options()
	_load_route(route_selected)
	for chi in Global.vehicle_shop:
		#print(chi)
		$Warehouse/Top/MarginContainer3/HBoxContainer/Vehicle.add_item(chi)
	$Warehouse/Top/MarginContainer3/HBoxContainer/Vehicle.select(0)
func _load_automobile() -> void:
	$Top/MenuBar/Automobile.add_item("Road")
	$Top/MenuBar/Automobile.add_item("Warehouse")
	$Top/MenuBar/Automobile.add_separator("Trucks")
	$Top/MenuBar/Automobile.add_submenu_item("Truck Station", "TruckStation")
	$Top/MenuBar/Automobile/TruckStation.add_item("/")
	$Top/MenuBar/Automobile/TruckStation.add_item("\\")
	
func _load_route_options() -> void:
	$Routing/Top/MarginContainer2/HBoxContainer/Options.add_item("No action")
	$Routing/Top/MarginContainer2/HBoxContainer/Options.add_item("Load available")
	$Routing/Top/MarginContainer2/HBoxContainer/Options.add_item("Wait for load")
	$Routing/Top/MarginContainer2/HBoxContainer/Options.add_item("Unload")
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
		if Input.is_action_just_released("1"):
			$Routing/Top/MarginContainer2/HBoxContainer/Options.select(0)
			_on_route_options_item_selected(0)
		if Input.is_action_just_released("2"):
			$Routing/Top/MarginContainer2/HBoxContainer/Options.select(1)
			_on_route_options_item_selected(1)
		if Input.is_action_just_released("3"):
			$Routing/Top/MarginContainer2/HBoxContainer/Options.select(2)
			_on_route_options_item_selected(2)
		if Input.is_action_just_released("4"):
			$Routing/Top/MarginContainer2/HBoxContainer/Options.select(3)
			_on_route_options_item_selected(3)
	else:
		$Top/Route.button_pressed = false
		$Routing.visible = false
	if Global.building_id_selected == -5:
		$Top/Warehouses.button_pressed = true
		$Warehouse.visible = true
	else:
		$Top/Warehouses.button_pressed = false
		$Warehouse.visible = false
	#print(seconds,", ",money_change,", ",seconds > 0.0 and not money_change == 0)
	if seconds > 0.0 and not money_change == 0:
		$MoneyChange.global_position = get_global_mouse_position() + Vector2(0,50*((seconds/2.0)-1))
		$MoneyChange.visible = true
	else:
		money_change = 0
		$MoneyChange.visible = false
	if not before_money == Global.money_base:
		var change = Global.money_base - before_money
		before_money = Global.money_base
		money_change += change
		seconds = 2.0
	if not money_change == 0:
		if money_change == abs(money_change):
			$MoneyChange.text = "+ " + Global._convert_currency(abs(money_change))
			$MoneyChange.add_theme_color_override("font_color", Color("00bd00",seconds/2.0))
		else:
			$MoneyChange.text = "- " + Global._convert_currency(abs(money_change))
			$MoneyChange.add_theme_color_override("font_color", Color("ff5455",seconds/2.0))
		seconds -= delta
		#print(seconds)
	$Money.text = Global._convert_currency(Global.money_base)
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
			#print(Global.building_id_selected)
			break

func _on_debug_id_pressed(id: int) -> void:
	var text = $Top/MenuBar/Debug.get_item_text(id)
	for building_source in Global.building_source:
		if building_source[0] == text:
			Global.building_id_selected = Global.building_source.find(building_source)
			#print(Global.building_id_selected)
			break

func _on_truck_station_id_pressed(id: int) -> void:
	Global.orientation_selected = id
	Global.building_id_selected = 4
	
func _add_to_route(miot):
	var find = Global.truck_stations.get(miot,[])
	if not find == []:
		var array = Global.routes.get_or_add(route_selected, [])
		print(array,", ", route_selected)
		array.push_back([miot,load_type_selected])
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
	if not warehouse_selected == Vector2i(-1,-1):
		selected_vehicle = $Warehouse/Top/MarginContainer3/HBoxContainer/Vehicle.get_item_text(index)
		if not selected_vehicle == "Nothing":
			var converted_cost = Global._convert_currency(Global.vehicle_shop[selected_vehicle][0])
			$Warehouse/Info/MarginContainer/Bottom/RichTextLabel.text = selected_vehicle+":\n\nCost:" + converted_cost
		else:
			$Warehouse/Info/MarginContainer/Bottom/RichTextLabel.text = "No Vehicle Selected"
		_load_warehouse_vehicles(warehouse_selected)
			#print(selected_vehicle)
	else:
		$Warehouse/Top/MarginContainer3/HBoxContainer/Vehicle.select(0)


func _on_buy_pressed() -> void:
	if not selected_vehicle == "Nothing":
		if Global.money_base >= Global.vehicle_shop[selected_vehicle][0]:
			Global.money_base -= Global.vehicle_shop[selected_vehicle][0]
			var warehouse:Array = Global.warehouses[warehouse_selected]
			Global.vehicles_n_i += 1
			warehouse[1].push_back([
				selected_vehicle,
				"Automobile #"+str(Global.vehicles_n_i)+" ("+Global.vehicle_shop[selected_vehicle][1]+")",
				warehouse_selected,
			])
			_load_warehouse_vehicles(warehouse_selected)
			_on_vehicle_id_value_changed(warehouse[1].size())
			#print("b")
			Global._send_to_main("Main","_vehicle",[warehouse_selected,"Automobile #"+str(Global.vehicles_n_i)+" ("+Global.vehicle_shop[selected_vehicle][1]+")",selected_vehicle])
			
func _load_warehouse_vehicles(warehouse):
	#print(Global.warehouses[warehouse_selected][1].size())
	
	for child in $Warehouse/Panel/MarginContainer/Bottom/VBoxContainer.get_children():
		child.queue_free()
	if warehouse == Vector2i(-1,-1) or Global.warehouses[warehouse] == []:
		var label = Label.new()
		label.text = "---No Vehicles Assigned---"
		$Warehouse/Panel/MarginContainer/Bottom/VBoxContainer.add_child(label)
		warehouse_selected = Vector2i(-1,-1)
		selected_vehicle = "Nothing"
		$Warehouse/Top/MarginContainer2/HBoxContainer/VehicleID.min_value = 0
		$Warehouse/Top/MarginContainer2/HBoxContainer/VehicleID.max_value = 1
		$Warehouse/Top/MarginContainer2/HBoxContainer/RouteID.value = 0
		$Warehouse/Top/MarginContainer/Title.text = "Select Warehouse"
		$Warehouse/Top/MarginContainer3/HBoxContainer/Vehicle.select(0)
	else:
		$Warehouse/Top/MarginContainer2/HBoxContainer/RouteID.value = float(Global.warehouses[warehouse_selected][2])
		$Warehouse/Top/MarginContainer2/HBoxContainer/VehicleID.min_value = min(1.0,Global.warehouses[warehouse_selected][1].size())
		var x = 0
		for child in Global.warehouses[warehouse][1]:
			x += 1
			var label = Label.new()
			label.text = "("+str(x)+"): " + child[1]
			#print(vehicle_id_selected)
			if x == vehicle_id_selected:
				label.add_theme_color_override("font_color", Color(0.85, 0.425, 0))
			$Warehouse/Panel/MarginContainer/Bottom/VBoxContainer.add_child(label)
		


func _on_vehicle_id_value_changed(value: float) -> void:
	#print(warehouse_selected)
	if not warehouse_selected == Vector2i(-1,-1):
		#print(value)
		$Warehouse/Top/MarginContainer2/HBoxContainer/VehicleID.min_value = min(1.0,Global.warehouses[warehouse_selected][1].size())
		#print(value)
		$Warehouse/Top/MarginContainer2/HBoxContainer/VehicleID.max_value = Global.warehouses[warehouse_selected][1].size()
		#print(int(value))
		vehicle_id_selected = int(value)
		$Warehouse/Top/MarginContainer2/HBoxContainer/VehicleID.value = value
		#print(vehicle_id_selected)
		_load_warehouse_vehicles(warehouse_selected)
	else:
		$Warehouse/Top/MarginContainer2/HBoxContainer/VehicleID.value = 0.0


func _on_sell_pressed() -> void:
	if not vehicle_id_selected == 0:
		var warehouse:Array = Global.warehouses[warehouse_selected]
		var vehicles:Array = warehouse[1]
		var vehicle:Array = vehicles[vehicle_id_selected-1]
		Global.money_base += Global.vehicle_shop[vehicle[0]][0] * 0.6
		vehicles.erase(vehicle)
		_on_vehicle_id_value_changed(vehicle_id_selected-1)
		_load_warehouse_vehicles(warehouse_selected)
		#print(vehicles)
		


func _on_warehouse_route_id_value_changed(value: float) -> void:
	if not warehouse_selected == Vector2i(-1,-1):
		Global.warehouses[warehouse_selected][2] = int(value)

func _external_load_selected_wrh() -> void:
	_load_warehouse_vehicles(warehouse_selected)
