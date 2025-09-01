extends CanvasGroup

var made = false
func _make_label(map_pos, local_pos):
	if not made:
		made = true
		position = local_pos
		$Label.text = str(map_pos)
		#print(map_pos,local_pos)
