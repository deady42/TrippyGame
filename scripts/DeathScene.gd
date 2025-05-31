extends VideoStreamPlayer

@onready var audioStreamPlayer = $AudioStreamPlayer
@onready var timer = $Timer


func _ready():
	get_window().move_to_center()
	
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_finished():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
