extends Node3D

@onready var zms3 = $ZMS3
@onready var sun = $Sun
@onready var playSprite = $Menu/StartMenu/PlaySprite
@onready var settingsSprite = $Menu/StartMenu/SettingsSprite
@onready var quitSprite = $Menu/StartMenu/QuitSprite
@onready var backSprite = $Menu/Settings/BackSprite
@onready var buttonTimer = $Menu/StartMenu/ButtonTimer
@onready var buttonAudio = $Menu/StartMenu/ButtonAudio
@onready var startMenu = $Menu/StartMenu
@onready var settings = $Menu/Settings
@onready var subViewport = $Menu/Settings/SubViewportContainer/SubViewport
@onready var masterAudioRegulator = $Menu/Settings/SubViewportContainer/SubViewport/MasterAudioRegulator
@onready var masterVolume = $Menu/Settings/MasterVolume
@onready var mouseSensitivityRegulator = $Menu/Settings/MouseSensitivityRegulator

var sunGate = false
var pressedButton
var masterAudioRegulatorMouseEnter = false
var isMousePressed = false

func _ready():
	mouseSensitivityRegulator.value = GlobalScript.mouseSensitivityMult
	masterAudioRegulator.rotation_degrees = GlobalScript.masterAudioRegulatorRotationDegrees
	masterVolume.text = str(int((GlobalScript.masterAudioRegulatorRotationDegrees - 90) / 7.2))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	if masterAudioRegulatorMouseEnter == true && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		isMousePressed = true
		masterAudioRegulator.look_at(subViewport.get_mouse_position())
		masterVolume.text = str(int(clamp((masterAudioRegulator.rotation_degrees - 90) / 7.2, -100, 100)))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), masterVolume.text.to_float() / 7.2)
		if masterAudioRegulator.rotation_degrees <= -720+90:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		else:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	elif isMousePressed == true && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) == false:
		print(masterAudioRegulator.rotation_degrees)
		masterAudioRegulator.rotation_degrees = clamp(masterAudioRegulator.rotation_degrees, -720 + 90, 720 + 90)
		GlobalScript.masterAudioRegulatorRotationDegrees = masterAudioRegulator.rotation_degrees
		isMousePressed = false
	
	zms3.rotation.y += delta * 3
	sun.rotation.z = - sun.global_position.x / 20 * PI
	if sun.global_position.x <= -40:
		sunGate = true
	elif sun.global_position.x >= 40:
		sunGate = false
	if sunGate == false:
		sun.global_position.x -= delta * 42
	else:
		sun.global_position.x += delta * 42

func _on_play_button_pressed():
	pressedButton = "play"
	buttonAudio.play()
	playSprite.play("pressed")
	buttonTimer.start()


func _on_settings_button_pressed():
	pressedButton = "settings"
	buttonAudio.play()
	settingsSprite.play("pressed")
	buttonTimer.start()


func _on_quit_button_pressed():
	pressedButton = "quit"
	buttonAudio.play()
	quitSprite.play("pressed")
	buttonTimer.start()

func _on_back_button_pressed():
	pressedButton = "back"
	buttonAudio.play()
	backSprite.play("pressed")
	buttonTimer.start()

func _on_button_timer_timeout():
	if pressedButton == "play":
		get_tree().change_scene_to_file("res://scenes/IntroVideo.tscn")
	elif pressedButton == "settings":
		startMenu.hide()
		settings.show()
		settingsSprite.play("default")
	elif pressedButton == "back":
		settings.hide()
		startMenu.show()
		backSprite.play("default")
	else:
		get_tree().quit()
	playSprite.frame = 0
	settingsSprite.frame = 0
	quitSprite.frame = 0
	backSprite.frame = 0


func _on_control_mouse_entered():
	masterAudioRegulatorMouseEnter = true


func _on_control_mouse_exited():
	masterAudioRegulatorMouseEnter = false

func _on_mouse_sensitivity_regulator_value_changed(value):
	GlobalScript.mouseSensitivityMult = mouseSensitivityRegulator.value
