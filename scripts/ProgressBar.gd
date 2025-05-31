extends Node2D

signal progressBarTimeout

@onready var characterBody = $CharacterBody2D
@onready var timer = $CharacterBody2D/Timer
@onready var moveAwayTimer = $CharacterBody2D/MoveAwayTimer
@onready var progressBar = $CharacterBody2D/TextureProgressBar
@onready var sprite = $CharacterBody2D/AnimatedSprite2D
@onready var label = $CharacterBody2D/Label

const height = -10
var gate = 0
var wasPreviouslyLoaded = false

func _ready():
	if GlobalScript.difficulty == 1:
		progressBar.value = 33

func _process(_delta):
	if timer.is_stopped() == true && wasPreviouslyLoaded == false:
		if GlobalScript.difficulty == 1:
			progressBar.value = 33
		else:
			progressBar.value = 213
			
	characterBody.move_and_slide()
	if gate == 1:
		if characterBody.position.y <= height:
			characterBody.velocity.y = 0
			characterBody.position.y = height
			gate = 0
	if gate == 2:
		if characterBody.position.y >= 96:
			characterBody.velocity.y = 0
			characterBody.position.y = 96
			gate = 0
			
func move_to_height():
	characterBody.velocity.y = - 32
	gate = 1

func move_away():
	moveAwayTimer.start()

func timer_start():
	if GlobalScript.difficulty >= 1:
		progressBar.max_value = 33
	timer.start()

func _on_timer_timeout():
	timer.start()
	if progressBar.value > 1:
		progressBar.value -= 1
		if int(progressBar.value) % 60 < 10 && int(progressBar.value) % 60 != 0:
			label.text = str(int(progressBar.value) / 60) + ":0" + str(int(progressBar.value) % 60)
		else:
			label.text = str(int(progressBar.value) / 60) + ":" + str(int(progressBar.value) % 60)
		if int(progressBar.value) % 60 == 0:
			label.text = label.text + "0"
	else:
		progressBar.value -= 1
		label.text = "0:00"
		sprite.play("loaded")
		timer.stop()
		wasPreviouslyLoaded = true
		emit_signal("progressBarTimeout")
		move_away()
		

func _on_move_away_timer_timeout():
	characterBody.velocity.y = 32
	gate = 2
