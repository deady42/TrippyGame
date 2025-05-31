extends CharacterBody3D

@export var bullet : PackedScene
@onready var enemy = load("res://scenes/Enemy.tscn")
@onready var player = $"../Player"
@onready var area = $Area3D
@onready var meleeDamageTimer = $MeleeDamageTimer
@onready var attackVariationTimer = $AttackVariationTimer

var health = 100
var second_stage_buff = 0
var speed = 9
var isMoving = true
var isShooting = false
var attackType = 0
var attackTypesNumber = 4

func _ready():
	set_physics_process(false)
	call_deferred("dump_first_physics_frame")

func _physics_process(_delta):
	if second_stage_buff == 0 && health <= 50:
		second_stage_buff = 1
	if attackType == 1:
		if player.is_on_floor():
			player.global_position += (global_position - player.global_position).normalized() * 0.1
		else:
			player.global_position += (global_position - player.global_position).normalized() * 0.25
	if isShooting == true:
		if attackType == 2:
			var projectile = bullet.instantiate() as Node3D
			get_parent().add_child(projectile)
			projectile.global_position = global_position
			projectile.velocity = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * projectile.speed
		else:
			var projectile = bullet.instantiate() as Node3D
			get_parent().add_child(projectile)
			projectile.global_position = global_position
	if is_instance_valid(player) && global_position.distance_to(player.global_position) > 0.1:
		look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP, true)
	if isMoving == true:
		velocity = (player.global_position - global_position).normalized() * speed
		move_and_slide()
	if area.monitoring == true:
		for a in area.get_overlapping_bodies():
			#// Если это игрок
			if a.get_collision_layer_value(2) == true && meleeDamageTimer.is_stopped():
				if a.isInvincible == false:
					a.health -= 1
					meleeDamageTimer.start()
					player.hurtAudio.play()
					#emit_signal("playerDamaged")
					print(a.health)
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/OutroVideo.tscn")

func dump_first_physics_frame() -> void:
	#wait until just before the second physics_frame is ready to go, then
		#re-enable _physics_process()
	if get_tree() != null:
		await get_tree().physics_frame
	set_physics_process(true)


func _on_area_3d_body_entered(body):
	if area.monitoring == true:
		if body.get_collision_layer_value(3) == true:
			health -= 1
			body.queue_free()

func _on_attack_variation_timer_timeout():
	attackVariationTimer.wait_time = 5.0
	speed = 4
	isShooting = false
	isMoving = true
	
	var attackTypes = []
	for i in range(attackTypesNumber):
		if attackType != i:
			attackTypes.append(i)
	if get_parent().enemyCounter >= 11:
		attackTypes.erase(3)
	if attackTypes.size() > 0:
		attackType = attackTypes.pick_random()
	
	#/// Ускориться
	if attackType == 0:
		speed = 9
	#/// Примагнитить игрока
	elif attackType == 1:
		isMoving = false
		velocity = Vector3.ZERO
		attackVariationTimer.wait_time = 2.0 / (second_stage_buff * 2.0 + float(GlobalScript.difficulty) * 2.0 + (1.0 - GlobalScript.difficulty))
	#/// Стрелять в случайных направлениях
	elif attackType == 2:
		isShooting = true
		attackVariationTimer.wait_time = 2.0 / (second_stage_buff * 2.0 + float(GlobalScript.difficulty) * 2.0 + (1.0 - GlobalScript.difficulty))
	#/// Заспавнить противников
	elif attackType == 3:
		if get_parent().enemyCounter < 11:
			for i in range(0, 5):
				var goon = enemy.instantiate() as Node3D
				get_parent().add_child(goon)
				goon.global_position = global_position + Vector3(randf_range(-10.0, 10.0), 1.0, randf_range(-10.0, 10.0))
				get_parent().enemyCounter += 1
			attackVariationTimer.wait_time = 3.0 / (second_stage_buff * 2.0 + float(GlobalScript.difficulty) * 2.0 + (1.0 - GlobalScript.difficulty))
		else:
			speed = 9
	print("Boss Attack Type: " + str(attackType))
	attackVariationTimer.start()
