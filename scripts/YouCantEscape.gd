extends Node2D

@onready var shaderMaterial = $Shader.material
@onready var staticAudio = $StaticAudio
@onready var timer = $Timer
@onready var label = $Label

var disintegrate = false
var fontSize = 128
var texts = ["YOU CAN'T ESCAPE", "THIS WILL NEVER END", "SUFFERING IS ENDLESS", "NEVER-ENDING FUN", "AGAIN"]

func _ready():
	GlobalScript.difficulty = 1
	var text = texts.pick_random()
	label.text = text
	#var voice_id = DisplayServer.tts_get_voices_for_language("en")[0]
	#DisplayServer.tts_speak(text, voice_id, 100, 0.0, 0.1)

func _physics_process(delta):
	if disintegrate:
		if timer.is_stopped():
			timer.start()
		fontSize = clamp(fontSize + 1, 128, 160)
		label.set("theme_override_font_sizes/font_size", fontSize)
		shaderMaterial.set_shader_parameter("distortion_factor", shaderMaterial.get_shader_parameter("distortion_factor") + 0.02)
		staticAudio.volume_db = lerp(staticAudio.volume_db, 24.0, 1.0 * delta)
		staticAudio.pitch_scale = lerp(staticAudio.pitch_scale, 0.3, delta)
func _on_timer_timeout():
	if !disintegrate:
		disintegrate = true
		staticAudio.play()
	else:
		get_tree().change_scene_to_file("res://scenes/Level1.tscn")
