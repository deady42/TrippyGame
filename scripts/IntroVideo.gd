extends VideoStreamPlayer

@onready var audioStreamPlayer = $AudioStreamPlayer


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GlobalScript.difficulty = 0

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_key_input(event: InputEvent):
	if GlobalScript.difficulty != 1 && Input.is_key_pressed(KEY_Z) && Input.is_key_pressed(KEY_M) && Input.is_key_pressed(KEY_S) && Input.is_key_pressed(KEY_3):
		GlobalScript.difficulty = 1
		audioStreamPlayer.play()
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/Level1.tscn")

func _on_finished():
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")
