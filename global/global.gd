extends Node

var debug = true

var road_changers = [0,3]

var width:int = 15#125
var height:int = 15#125
var altitude:float = 0

var industries_per_100 = 0#5

var sprite = []
var loaded_sprite = []

var done_loading = false

var truck_stations = {} # { (0,0): [0,"Truck Station 1"]}
var truck_stations_n_i = 0

var routes = {} # { 0: [[(0,0), 0], [(2,3), 3]]}

var warehouses = {}
var warehouses_n_i = 0
var vehicles_n_i = 0

var map_to_local = {}

var vehicle_shop = {
	"Industrial Goods Truck": [10000, "Indstr", "res://asset/pictures/vehicles/IndustrialGoodsTruck", ".png"]
}

var seed:int = -1

var error_pop_up = {"Title": "Nil", "Description": "Nil"}

var mouse_in_menu = false

var built:Array = []
var built_data:Array = []

var building_id_selected = -1
var orientation_selected = 0

var money_base = 100000

var conversion_selected = 0
var money_conversions = [
	["Pound","£",1,false,],
	["Dollar","$",2,false],
	["Euro","€",2,false],
	["Koruna","Kč",28,true],
	["Shekel","₪",4,false],
	["Bolivar (2021)","VES (2021)",5711960,true],
	#["WeinBucks","WnB",1,true]
]

var building_source = [
	[
		"Road", # Real Name
		"res://asset/pictures/buildings/roads/RoadOrientation", # File Location
		".png", # File Format
		true, # Removable
		[], # Procedu-Generated (Check Power Plant for true)
		0, # ZIndex
		0, # Max Orientation
		100,
	],
	[
		"Power Plant",
		"res://asset/pictures/buildings/PowerPlant",
		".png",
		false,
		[ # True P-G
			50, # Social Distancing - New industries can not be place with in _ of this industry
			[8,2], # Extra (places more industies of the same type around) (How many, How far)
			[
				"res://asset/pictures/buildings/PowerPlant0.png",
				"res://asset/pictures/buildings/PowerPlant1.png",
				"res://asset/pictures/buildings/PowerPlant2.png",
				"res://asset/pictures/buildings/PowerPlant3.png",
				"res://asset/pictures/buildings/PowerPlant4.png",
			], # Sprites For Extra
			false, # Pollutes
			-1, #Connects to, (what industry to auto gen next)
		],
		1,
		0,
		0,
	],
	[
		"Coal Mine",
		"res://asset/pictures/buildings/CoalMine",
		".png",
		false,
		[
			75,
			[5,2],
			[
				"res://asset/pictures/buildings/CoalMine0.png",
				"res://asset/pictures/buildings/CoalMine1.png"
			],
			true, # Pollutes
			1, #Connects to, (what industry to auto gen next)
		],
		1,
		0,
		0,
	],
	[
		"Warehouse", # Real Name
		"res://asset/pictures/buildings/Warehouse", # File Location
		".png", # File Format
		true, # Removable
		[], # Procedu-Generated (Check Power Plant for true)
		1, # ZIndex
		0,
		1000,
	],
	[
		"Truck Station",
		"res://asset/pictures/buildings/TruckStation",
		".png",
		true,
		[], 
		1, 
		1,
		2000,
	],
]

var proc_buildings = [2]

func _build(coords:Vector2i,_coords_local):
	if not building_id_selected == -1:
		var find = built.find(coords)
		#print(find,",",coords)
		if building_id_selected == -4:
			get_tree().call_group("GameplayUI", "_add_to_route", coords)
		elif building_id_selected == -5:
			get_tree().call_group("GameplayUI", "_select_warehouse", coords)
		elif building_id_selected == -2 and not find == -1:
			return _remove(find)
		elif not building_id_selected == -2:
			var get_from_source = building_source[building_id_selected]
			if find == -1:
				built.push_front(coords)
				built_data.push_front(
					[
						get_from_source[0],
						building_id_selected,
						Global.orientation_selected
					]
				)
				money_base -= get_from_source[7] * 0.8
				if building_id_selected == 4:
					truck_stations.get_or_add(coords)
					truck_stations_n_i += 1
					truck_stations[coords] = [orientation_selected, "Truck Station #" + str(truck_stations_n_i), false, {}]
					#print(truck_stations)
				elif building_id_selected == 3:
					warehouses.get_or_add(coords)
					warehouses_n_i += 1
					warehouses[coords] = ["Truck Warehouse #" + str(warehouses_n_i),[],-1]
			else:
				built_data[find] = [
					get_from_source[0],
					built_data[find][1],
					built_data[find][2]
				]
				#print(built_data[find])
			#print(get_from_source[3])
			#print(built,built_data)
			return find
	return -3
func _remove(array_location):
	if building_source[built_data[array_location][1]][3] == true:
		if built_data[array_location][1] == 4:
			truck_stations.erase(built[array_location])
			#print(truck_stations)
		if built_data[array_location][1] == 3:
			warehouses[built[array_location]] = []
			print(warehouses)
			get_tree().call_group("GameplayUI","_external_load_selected_wrh")
			#print(truck_stations)
		built.remove_at(array_location)
		built_data.remove_at(array_location)
		money_base += building_source[built_data[array_location][1]][7] * 0.4
		return -2
	error_pop_up = {"Title": "Invalid Action.", "Description": "One of the buildings you tried to destroy is unremovable (i.e. Industries)."}
	return -3
	
func _get_building_info_of_v2i(v2i:Vector2i):
	var get_array_location = built.find(v2i)
	if get_array_location == -1:
		return []
	else:
		return built_data[get_array_location]
		
func _convert_currency(money):
	if money_conversions[conversion_selected][3] == false:
		return money_conversions[conversion_selected][1] + " " + str(money*money_conversions[conversion_selected][2])
	else:
		return str(money*money_conversions[conversion_selected][2]) + " " + money_conversions[conversion_selected][1]
	return ""

func _send_to_main(group,funct,stuff) -> void:
	get_tree().call_group(group,funct,stuff)
	
func _day_tick() -> void:
	await get_tree().create_timer(0.2, true, true).timeout
	for t in truck_stations:
		var truck_station = truck_stations[t]
		if truck_station[2]:
			for x in 5:
				print(x)
				x = x - 3
				for y in 5:
					y = y -3
					var xy = Vector2i(x,y)
					var gbi = _get_building_info_of_v2i(xy)
					if not gbi == []:
						var resources:Dictionary = truck_station[3]
						if gbi[1] == 2:
							resources.get_or_add("Coal",0)
							resources["Coal"] += 10
