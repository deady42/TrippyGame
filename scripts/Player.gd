extends CharacterBody3D

signal playerProgressBarTimeout

@export var bullet : PackedScene
@onready var healthRegenTimer = $HealthRegenTimer
@onready var weaponAnimation = $TwistPivot/PitchPivot/Weapon/WeaponAnimationPlayer
@onready var itemAnimation = $TwistPivot/PitchPivot/Item/ItemAnimationPlayer
@onready var hurtAudio = $HurtAudio
@onready var jumpAudio = $JumpAudio
@onready var timerWatchAudio = $TimerWatchAudio
@onready var twistPivot := $TwistPivot
@onready var pitchPivot := $TwistPivot/PitchPivot
@onready var collisionShape = $CollisionShape3D
@onready var item = $TwistPivot/PitchPivot/Item
@onready var shaderMesh = $TwistPivot/PitchPivot/Shader
@onready var shaderMaterial = $TwistPivot/PitchPivot/Shader.get_active_material(0)
@onready var shakeTimer = $ShakeTimer
@onready var gunshotSound = $TwistPivot/PitchPivot/Weapon/GunshotSound
@onready var mazeSolution = $"../Maze/Solution"
@onready var mazeMesh = $"../Maze/MeshInstance3D"
@onready var healthLabel = $TwistPivot/PitchPivot/Camera3D/MarginContainer/HealthLabel
@onready var progressBar = $TwistPivot/PitchPivot/Camera3D/ProgressBar
@onready var secondaryCooldown = $SecondaryCooldown
@onready var secondaryTimer = $SecondaryTimer
@onready var secondaryAudio = $SecondaryAudio
@onready var secondaryParticles = $SecondaryParticles
@onready var gameSettings = $TwistPivot/PitchPivot/Camera3D/GameSettings
@onready var blackoutScreen = $TwistPivot/PitchPivot/Camera3D/ColorRect
@onready var vignette = $TwistPivot/PitchPivot/Camera3D/Vignette
@onready var jumpLabel = $TwistPivot/PitchPivot/Camera3D/JumpLabel
@onready var timerWatch = $TwistPivot/PitchPivot/Camera3D/MarginContainer/TimerWatch
@onready var timerWatchTimer = $TwistPivot/PitchPivot/Camera3D/MarginContainer/TimerWatch/TimerWatchTimer
@onready var timerWatchShader = $TwistPivot/PitchPivot/Camera3D/MarginContainer/TimerWatch/CanvasLayer/TimerWatchShader
@onready var timeLabel = $TwistPivot/PitchPivot/Camera3D/MarginContainer/TimerWatch/TimeLabel
@onready var buttonAudio = $TwistPivot/PitchPivot/Camera3D/GameSettings/ButtonAudio
@onready var buttonTimer = $TwistPivot/PitchPivot/Camera3D/GameSettings/ButtonTimer
@onready var mainMenuSprite = $TwistPivot/PitchPivot/Camera3D/GameSettings/MainMenuSprite
@onready var zmsModeMusic = $Zms3ModeMusic
@onready var menuAccessDeniedLabel = $TwistPivot/PitchPivot/Camera3D/GameSettings/MenuAccessDeniedLabel
var mazeMap
var pressedButton

var isInvincible = false
var posterizationGate = false
var shakeGate = false
var health = 10
var speed = 5.0
const jumpPower = 4.2
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouseSensitivity := 0.000005
var twistInput := 0.0
var pitchInput := 0.0
var direction = Vector3.ZERO
var piskaPicked = false
var screenBlackoutGate = false
var timerWatchTime = 813
var timerWatchAmplitude = 0.0

func _ready():
	if GlobalScript.difficulty >= 1:
		if get_parent().name == "BossLevel1":
			timerWatchTime = GlobalScript.savedTimerWatchTime
		if timerWatchTime % 60 >= 10:
			timeLabel.text = str(timerWatchTime / 60) + ":" + str(timerWatchTime % 60)
		elif timerWatchTime % 60 == 0:
			timeLabel.text = str(timerWatchTime / 60) + ":00"
		else:
			timeLabel.text = str(timerWatchTime / 60) + ":0" + str(timerWatchTime % 60)
		timerWatch.show()
		timerWatchShader.show()
		timerWatchTimer.start()
	
	if is_instance_valid($MazeMap):
		mazeMap = $MazeMap
	
	mouseSensitivity = 0.000005 * GlobalScript.mouseSensitivityMult
	if shaderMaterial.get_shader_parameter("is_posterization_enabled") == true:
		shaderMaterial.set_shader_parameter("is_posterization_enabled", false)
	shakeTimer.wait_time = 0.1 - GlobalScript.difficulty * 0.05 #Affected by difficulty
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if GlobalScript.difficulty >= 1:
		timerWatch.rotation = timerWatchAmplitude * sin(timerWatchAmplitude * 50.0)
		timerWatchAmplitude = lerp(timerWatchAmplitude, 0.0, 5.0 * delta)
		if timerWatchTimer.is_stopped():
			timerWatch.show()
			timerWatchShader.show()
			timerWatchTimer.start()
	else:
		timerWatch.hide()
		timerWatchShader.hide()
		timerWatchTimer.stop()
	
	#/// Прозрачность виньетки поверапа стремится к нулю
	vignette.modulate.a = lerp(vignette.modulate.a, 0.0, delta)
	
	#/// Чёрный экран затемнения для прогрузок других локаций
	if screenBlackoutGate == true:
		blackoutScreen.color.a = lerp(blackoutScreen.color.a, 1.0, 5.0 * delta)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("CalmMusic"), -blackoutScreen.color.a * 40.0)
	else:
		blackoutScreen.color.a = lerp(blackoutScreen.color.a, 0.0, delta)
	
	#/// Реген ХП, вывод его количества в label
	if health < 10 && healthRegenTimer.is_stopped() == true:
		healthRegenTimer.start()
	healthLabel.text = "zms3 has " + str(health) + " health!"
	#if Input.is_action_pressed("action_z") && shakeGate == false:
	
	#/// Чит, при зажатии z+m+s показывается решение лабиринта (Если Писька не подобрана)
	if Input.is_action_pressed("action_z") && piskaPicked == false:
		if Input.is_action_pressed("action_m"):
			if Input.is_action_pressed("action_s") && is_instance_valid(mazeSolution):
				if mazeSolution.is_visible() == false:
					mazeSolution.show()
	else:
		if is_instance_valid(mazeSolution):
		#if mazeSolution.is_visible() && shakeGate == false:
			if mazeSolution.is_visible() && piskaPicked == false:
				mazeSolution.hide()
	
	#/// Чит, при зажатии 3 прячется mesh лабиринта, иначе показывается снова
	if is_instance_valid(mazeMesh):
		if Input.is_action_pressed("action_3"):
			mazeMesh.hide()
		else:
			if mazeMesh.is_visible() == false:
				mazeMesh.show()
	
	
	if Input.is_action_pressed("shoot") && weaponAnimation.is_playing() == false:
		weaponAnimation.play("weapon_fire")
		gunshotSound.play()
		var projectile = bullet.instantiate() as Node3D
		get_parent().add_child(projectile)
		projectile.global_position = Vector3(self.global_position.x - sin(twistPivot.rotation.y) * cos(pitchPivot.rotation.x), self.global_position.y + sin(pitchPivot.rotation.x), self.global_position.z - cos(twistPivot.rotation.y) * cos(pitchPivot.rotation.x))
	
	if Input.is_action_just_pressed("secondary") && piskaPicked == true && GlobalScript.difficulty != 1:
		if secondaryCooldown.is_stopped():
			vignette.modulate.a = 1.0
			if is_instance_valid(mazeSolution):
				mazeSolution.show()
			secondaryTimer.start()
			secondaryCooldown.start()
			itemAnimation.play("item_use")
			secondaryAudio.play()
			secondaryParticles.emitting = true
			isInvincible = true
	
	if Input.is_action_just_pressed("map_toggle") && is_instance_valid(mazeMap):
		if mazeMap.is_visible():
			mazeMap.hide()
		else:
			mazeMap.show()
	
	if Input.is_action_just_pressed("action_z") && $GoydaAudio.playing == false:
		$GoydaAudio.play()
	
	#/// Если ХП равно или меньше нуля, то смерть
	if health <=0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if GlobalScript.difficulty >= 1:
			get_tree().change_scene_to_file("res://scenes/YouCantEscape.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/DeathScene.tscn")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jumpPower
		jumpAudio.play()
	if Input.is_action_pressed("move_run"):
		speed = 10.0
	if Input.is_action_just_released("move_run"):
		speed = 5.0
	
	var inputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if is_on_floor():
		direction = lerp(direction, (twistPivot.transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized(), delta*10.0)
	else:
		if inputDir != Vector2.ZERO:
			direction = lerp(direction, (twistPivot.transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized(), delta*3.0)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		twistPivot.rotation_degrees.z = lerp(twistPivot.rotation_degrees.z, -inputDir.x * 5, 5 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	twistPivot.rotate_y(twistInput)
	pitchPivot.rotate_x(pitchInput)
	collisionShape.rotate_y(twistInput)
	pitchPivot.rotation.x = clamp(pitchPivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	twistInput = 0.0
	pitchInput = 0.0
		
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twistInput = - event.relative.x * mouseSensitivity
			pitchInput = - event.relative.y * mouseSensitivity

func get_twist_rotation():
	return twistPivot.rotation

func get_pitch_rotation():
	return pitchPivot.rotation

func toggle_item_visibility():
	if item.visible == false:
		item.show()
	else:
		item.hide()

func toggle_posterization_shader():
	if posterizationGate == false:
		shaderMaterial.set_shader_parameter("is_posterization_enabled", true)
		posterizationGate = true
	else:
		shaderMaterial.set_shader_parameter("is_posterization_enabled", false)
		posterizationGate = false

func shake_toggle():
	if shakeGate == false:
		shakeTimer.start()
		shakeGate = true
		mazeSolution.show()
	else:
		shakeGate = false
		if posterizationGate == true:
			toggle_posterization_shader()
		twistPivot.position = Vector3.ZERO
		shakeTimer.stop()
		mazeSolution.hide()

func _on_shake_timer_timeout():
	twistPivot.position = Vector3(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), 0)
	if secondaryTimer.is_stopped() && posterizationGate == true:
		mazeSolution.hide()
	if randi_range(0, 10) == 0:
		toggle_posterization_shader()
		if mazeSolution.is_visible() && secondaryTimer.is_stopped() && posterizationGate == true:
			mazeSolution.hide()
		else:
			mazeSolution.show()

func _on_health_regen_timer_timeout():
	if health < 10:
		health += 1

func _on_piska_piska_picked():
	piskaPicked = true
	toggle_item_visibility()
	shake_toggle()
	if is_instance_valid($MazeMap):
		$MazeMap.queue_free()
	progressBar.move_to_height()
	progressBar.timer_start()

func _on_progress_bar_progress_bar_timeout():
	emit_signal("playerProgressBarTimeout")

func _on_secondary_timer_timeout():
	isInvincible = false
	if posterizationGate == true && is_instance_valid(mazeSolution):
		mazeSolution.hide()

func _on_game_settings_mouse_sensitivity_value_changed():
	mouseSensitivity = 0.000005 * GlobalScript.mouseSensitivityMult

func _on_timer_watch_timer_timeout():
	timerWatchTime -= 1
	if timerWatchTime == 300:
		timerWatchAudio.stream = load("res://audio/5_minutes_remain.mp3")
		timerWatchAudio.play()
		AudioServer.set_bus_mute(1, true)
		AudioServer.set_bus_mute(2, true)
		zmsModeMusic.play()
	elif timerWatchTime == 120:
		timerWatchAudio.stream = load("res://audio/2_minutes_remain.mp3")
		timerWatchAudio.play()
	elif timerWatchTime == 30:
		timerWatchAudio.stream = load("res://audio/30_seconds_remain.mp3")
		timerWatchAudio.play()
	elif timerWatchTime == 10:
		timerWatchAudio.stream = load("res://audio/10_seconds_remain.mp3")
		timerWatchAudio.play()
	elif timerWatchTime < 0:
		get_tree().change_scene_to_file("res://scenes/YouCantEscape.tscn")
	timerWatchAmplitude = PI / 8.0
	if timerWatchTime % 60 >= 10:
		timeLabel.text = str(timerWatchTime / 60) + ":" + str(timerWatchTime % 60)
	elif timerWatchTime % 60 == 0:
		timeLabel.text = str(timerWatchTime / 60) + ":00"
	else:
		timeLabel.text = str(timerWatchTime / 60) + ":0" + str(timerWatchTime % 60)

func _on_main_menu_button_pressed():
	pressedButton = "main_menu"
	buttonAudio.play()
	mainMenuSprite.play("pressed")
	buttonTimer.start()
	menuAccessDeniedLabel.show()
	#await get_tree().create_timer(1).timeout

func _on_button_timer_timeout():
	if pressedButton == "main_menu":
		if GlobalScript.difficulty == 0:
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		else:
			mainMenuSprite.play("default")
			menuAccessDeniedLabel.hide()
