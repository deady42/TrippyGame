extends Node2D

@onready var subViewport = $SubViewportContainer/SubViewport
@onready var label = $SubViewportContainer/SubViewport/PanelContainer/Label
@onready var timer = $Timer
@onready var zms3ModeStamp = $SubViewportContainer/SubViewport/Zms3ModeStamp
@onready var zms3ModeStar = $Zms3ModeStar

func _ready():
	if GlobalScript.difficulty == 1:
		zms3ModeStamp.show()
		zms3ModeStar.show()
	get_window().borderless = false
	#get_window().size = Vector2i(1080, 720)
	get_window().move_to_center()
	var text = "Грамота присуждается игроку\nXXXXXXXXXX\nза победу в игре\nhappy_emoji_3!"
	if OS.has_environment("USERNAME"):
		label.text = "Грамота присуждается игроку\n" + OS.get_environment("USERNAME") + "\nза победу в игре\nhappy_emoji_3!"
	else:
		label.text = text

func _process(delta):
	if timer.is_stopped() == false:
		var img = subViewport.get_texture().get_image()
		img.save_png("./diploma.png")
