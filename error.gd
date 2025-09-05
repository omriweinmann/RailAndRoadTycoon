extends Control

func _process(_delta: float) -> void:
	if Global.error_pop_up["Title"] == "Nil":
		visible = false
	else:
		visible = true
		$TotalPanel/Top/Title.text = Global.error_pop_up["Title"]
		$TotalPanel/Bottom/Description.text = Global.error_pop_up["Description"]

func _on_close_pressed() -> void:
	Global.error_pop_up["Title"] = "Nil"
