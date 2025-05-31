class_name  Enemy
extends CharacterBody3D

#@export var player_path : NodePath
@onready var timer = $Timer
@onready var area = $Area3D
@onready var mesh = $MeshInstance3D
@onready var nav = $NavigationAgent3D
@onready var collisionShape = $CollisionShape3D
@onready var player = $"../Player"
@onready var audioStreamPlayer3D = $AudioStreamPlayer3D
@onready var deathAnimationTimer = $DeathAnimationTimer
@onready var subviewportAnimatedSprite = $MeshInstance3D/SubViewport/AnimatedSprite2D
@onready var gpuParticles = $GPUParticles3D


var health = 3 + GlobalScript.difficulty * 7 #Affected by difficulty
var speed = 3 + GlobalScript.difficulty * 2 #Affected by difficulty
var direction = Vector3()
var gravityHolder = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var deathType = 0
var isDead = false

func _ready():
	set_physics_process(false)
	call_deferred("dump_first_physics_frame")
	#player = get_node(player_path)

func _physics_process(delta):
	if not is_on_floor() && isDead == false:
		velocity.y -= gravity * delta
		gravityHolder -= gravity * delta
	else:
		gravityHolder = 0
	if is_instance_valid(player):
		###nav.target_position = player.global_position
		###var next_position = nav.get_next_path_position()
		look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP, true)
		if chase_player_in_range() == true && isDead == false:
			###direction = (next_position - global_position).normalized()
			direction = (player.global_position - global_position).normalized()
			velocity = velocity.lerp(direction * speed, 10 * delta)
			#velocity = (player.global_position - global_transform.origin).normalized() * speed
			velocity.y = gravityHolder
		else:
			velocity.x = 0
			velocity.z = 0
	move_and_slide()
	if health <= 0 && isDead == false: #health > -10:
		die()
		#health = -10 #Костыль чтобы скрипт die() не срабатывал много раз
	if area.monitoring == true:
		for a in area.get_overlapping_bodies():
			#// Если это игрок
			if a.get_collision_layer_value(2) == true && timer.is_stopped():
				if a.isInvincible == false:
					a.health -= 1
					timer.start()
					player.hurtAudio.play()
					#emit_signal("playerDamaged")
					print(a.health)


func _on_area_3d_body_entered(body):
	if area.monitoring == true:
		if body.get_collision_layer_value(3) == true:
			health -= 1
			body.queue_free()
		#if body.get_collision_layer_value(2) == true:
			#body.health -= 1
			#print(body.health)

func chase_player_in_range():
	if is_instance_valid(player):
		return global_position.distance_to(player.global_position) < 500
	else:
		return false
		
func dump_first_physics_frame() -> void:
	#wait until just before the second physics_frame is ready to go, then
		#re-enable _physics_process()
	if get_tree() != null:
		await get_tree().physics_frame
	set_physics_process(true)

func die():
	isDead = true
	deathType = randi_range(0, 2)
	if deathType == 0:
		get_parent().enemyCounter -= 1
		deathAnimationTimer.wait_time = 1.2
		deathAnimationTimer.start()
		velocity = Vector3.ZERO
		audioStreamPlayer3D.play()
		collisionShape.disabled = true
		area.monitoring = false
		area.disable_mode = true
	if deathType == 1:
		audioStreamPlayer3D.stream = load("res://audio/emoji_26_fall_scream.mp3")
		set_collision_mask_value(1, false)
		area.monitoring = false
		area.disable_mode = true
		audioStreamPlayer3D.play()
		velocity.y = -9.8
	if deathType == 2:
		get_parent().enemyCounter -= 1
		audioStreamPlayer3D.stream = load("res://audio/emoji_26_disappear_scream.mp3")
		mesh.hide()
		area.monitoring = false
		area.disable_mode = true
		audioStreamPlayer3D.play()
		deathAnimationTimer.wait_time = 2.0
		deathAnimationTimer.start()
	print("enemyCounter = ", get_parent().enemyCounter)

func _on_death_animation_timer_timeout():
	if deathType == 0:
		subviewportAnimatedSprite.play("death")
		gpuParticles.emitting = true
	if deathType == 2:
		queue_free()


func _on_animated_sprite_2d_animation_finished():
	queue_free()
