extends Node

var isPaused = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if is_instance_valid(get_parent().gameSettings):
				get_parent().gameSettings.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if isPaused == false:
				get_tree().paused = true
				if is_instance_valid(get_parent().mazeMap):
					get_parent().mazeMap.hide()
		else:
			if is_instance_valid(get_parent().gameSettings):
				get_parent().gameSettings.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			if isPaused == false:
				get_tree().paused = false

func pause():
	if get_tree() != null:
		if isPaused == false:
			isPaused = true
			get_tree().paused = true
		else:
			isPaused = false
			get_tree().paused = false
	#if get_tree().paused == false && Input.MOUSE_MODE_VISIBLE == 0:
		#get_tree().paused = true
	#if get_tree().paused == true && Input.MOUSE_MODE_VISIBLE == 1:
		#get_tree().paused = false
