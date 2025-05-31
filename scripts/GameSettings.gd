extends Control

signal mouseSensitivityValueChanged

@onready var masterAudioRegulator = $SubViewportContainer/SubViewport/MasterAudioRegulator
@onready var masterVolume = $MasterVolume
@onready var subViewport = $SubViewportContainer/SubViewport
@onready var mouseSensitivityRegulator = $MouseSensitivityRegulator
@onready var pauseScreenBackground = $PauseScreenBackground

var masterAudioRegulatorMouseEnter = false
var isMousePressed = false

var cosBG = 0.0
var sinBG = 0.0

func _ready():
	mouseSensitivityRegulator.value = GlobalScript.mouseSensitivityMult
	masterAudioRegulator.rotation_degrees = GlobalScript.masterAudioRegulatorRotationDegrees
	masterVolume.text = str(int((GlobalScript.masterAudioRegulatorRotationDegrees - 90) / 7.2))

func _process(delta):
	cosBG += delta
	sinBG += delta
	pauseScreenBackground.position = Vector2(cos(cosBG) * 100, sin(sinBG) * 14)
	
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

func _on_control_mouse_entered():
	masterAudioRegulatorMouseEnter = true


func _on_control_mouse_exited():
	masterAudioRegulatorMouseEnter = false

func _on_mouse_sensitivity_regulator_value_changed(value):
	GlobalScript.mouseSensitivityMult = mouseSensitivityRegulator.value
	emit_signal("mouseSensitivityValueChanged")
