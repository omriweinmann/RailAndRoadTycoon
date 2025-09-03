extends Control

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

func _on_automobile_id_pressed(id: int) -> void:
	var text = $Top/MenuBar/Automobile.get_item_text(id)
	for building_source in Global.building_source:
		if building_source[0] == text:
			Global.building_id_selected = Global.building_source.find(building_source)
			break


func _on_destroy_toggled(toggled_on: bool) -> void:
	#print(toggled_on == true)
	if toggled_on == true:
		Global.building_id_selected = -2
	elif Global.building_id_selected == -2:
		Global.building_id_selected = -1
	#print(Global.building_id_selected)
