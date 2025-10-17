extends Node3D

#@export var enemyScene : PackedScene
@onready var enemyScene = load("res://scenes/Enemy.tscn")
@onready var window = get_window()
@onready var shakeTimer = $ShakeTimer
@onready var enemySpawnTimer = $EnemySpawnTimer
@onready var player = $Player
@onready var music = $Music
@onready var levelEndArea = $LevelEndArea
@onready var videoStreamPlayer = $Maze/MeshInstance3D/SubViewport/VideoStreamPlayer
@onready var exitDoor = $Maze/ExitDoor
@onready var playerTauntAudio = $PlayerTauntAudio
@onready var groundParticles = $StaticBody3D/GroundParticles
@onready var groundTrembleTimer = $GroundTrembleTimer
@onready var groundTrembleAudio = $GroundTrembleAudio
@onready var levelEndTimer = $LevelEndTimer


var levelEndGate = false
var enemyCounter = 0
var xNegative = 1
var zNegative = 1
var gate = false
var windowPosition = Vector2i()
var tauntEnemyCounter = 0
var tremble = 0.0
var groundTrembleTimerMode = false

func _ready():
	AudioServer.set_bus_mute(1, false)
	AudioServer.set_bus_mute(2, false)
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("EnemyAudio"), 0, false)
	groundTrembleTimer.wait_time = randf_range(10.0, 30.0)
	groundTrembleTimer.start()
	groundTrembleTimer.wait_time = 0.6

func _process(delta):
	if player.piskaPicked == true && tremble > 0.1: #0.1 это сила тряски экрана после подбора Письки
		player.twistPivot.position = Vector3(randf_range(-tremble, tremble), randf_range(-tremble, tremble), 0)
	elif player.piskaPicked == false && tremble > 0.0:
		player.twistPivot.position = Vector3(randf_range(-tremble, tremble), randf_range(-tremble, tremble), 0)
	if player.piskaPicked == false && tremble < 0.0001:
		tremble = 0.0
	else:
		tremble = lerp(tremble, 0.0, 5 * delta)
		
	
	if tauntEnemyCounter < enemyCounter:
		tauntEnemyCounter = enemyCounter
	elif tauntEnemyCounter > enemyCounter:
		if randf() > 0.95 && playerTauntAudio.playing == false:
			playerTauntAudio.play()
		tauntEnemyCounter = enemyCounter
	if enemyCounter < 42 && enemySpawnTimer.is_stopped():
		enemySpawnTimer.start()
		print("spawned")
		print("enemyCounter = ", enemyCounter)
	if levelEndArea.body_exited && levelEndGate == true:
		if GlobalScript.difficulty >= 1:
			GlobalScript.savedTimerWatchTime = player.timerWatchTime
		get_tree().change_scene_to_file("res://scenes/BossLevel1.tscn")
		levelEndGate = false
		

func window_shake_toggle():
	if gate == false:
		windowPosition = get_window().position
		shakeTimer.start()
		gate = true
	else:
		shakeTimer.stop()
		gate = false


func _on_shake_timer_timeout():
	#window.position = Vector2i(windowPosition.x + randi_range(-5, 5), windowPosition.y + randi_range(-5, 5))
	window.position = Vector2i(windowPosition.x + randi_range(-100, 100), windowPosition.y + randi_range(-100, 100))


func _on_enemy_spawn_timer_timeout():
	if randi_range(0, 1) == 0:
		xNegative = -1
	else:
		xNegative = 1
	if randi_range(0, 1) == 0:
		zNegative = -1
	else:
		zNegative = 1
	var enemy = enemyScene.instantiate() as Node3D
	add_child(enemy)
	#enemy.global_position = Vector3(player.global_position.x + 2, 1, player.global_position.z)
	enemy.global_position = player.global_position + Vector3(xNegative * randf_range(5, 10), 6, zNegative * randf_range(5, 10))
	enemyCounter += 1


func _on_music_finished():
	music.stream = load("res://audio/run_repeat.mp3")
	music.play()


func _on_level_end_area_body_entered(body):
	if body.get_collision_layer_value(2):
		player.screenBlackoutGate = true
		levelEndTimer.start()
		#levelEndGate = true
	if body.get_collision_layer_value(4):
		body.queue_free()
		enemyCounter -= 1
		tauntEnemyCounter = enemyCounter
		print("enemy was queue_freed")
		print("enemyCounter = ", enemyCounter)


func _on_piska_piska_picked():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("CalmMusic"), 0)
	music.stream = load("res://audio/run.mp3")
	music.play()
	videoStreamPlayer.play()
	exitDoor.set_collision_layer_value(1, false)
	exitDoor.set_collision_layer_value (5, true)
	#if GlobalScript.difficulty == 1:
		#window_shake_toggle()


func _on_ground_tremble_timer_timeout():
	if groundTrembleTimerMode == false:
		groundTrembleTimer.wait_time = randf_range(10.0, 30.0)
		groundTrembleAudio.play()
		player.jumpLabel.show()
		groundTrembleTimerMode = true
		print(groundTrembleTimer.wait_time)
	else:
		groundParticles.restart()
		player.jumpLabel.hide()
		if player.is_on_floor():
			tremble += 1.0
			if player.isInvincible == false:
				player.health -= 3 + 999 * GlobalScript.difficulty
				player.hurtAudio.play()
		else:
			tremble += 0.5
		groundTrembleTimer.wait_time = 0.6
		groundTrembleTimerMode = false

func _on_level_end_timer_timeout():
	levelEndGate = true
