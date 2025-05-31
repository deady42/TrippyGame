extends VideoStreamPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_window().borderless = true
	#get_window().size = Vector2i(1080, 720)
	get_window().move_to_center()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/Diploma.tscn")

func _on_finished():
	get_tree().change_scene_to_file("res://scenes/Diploma.tscn")
