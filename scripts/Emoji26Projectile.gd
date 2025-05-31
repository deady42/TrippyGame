extends CharacterBody3D

@onready var player = get_parent().get_node("Player")
@onready var boss = get_parent().get_node("Boss")
@onready var mesh = $MeshInstance3D
@onready var area = $Area3D

const speed = 15

func _ready():
	velocity = -Vector3(-sin(boss.rotation.y) * cos(boss.rotation.x) * speed, sin(boss.rotation.x) * speed, -cos(boss.rotation.y) * cos(boss.rotation.x) * speed)
	#velocity = Vector3(-sin(boss.rotation.y) * cos(boss.rotation.x) * speed, sin(boss.rotation.x) * speed, -cos(boss.rotation.y) * cos(boss.rotation.x) * speed)
	#print(velocity.normalized())
	mesh.rotation = Vector3(player.get_pitch_rotation().x, player.get_twist_rotation().y, player.get_pitch_rotation().z)

func _physics_process(delta):
	if is_instance_valid(player):
		mesh.rotation = Vector3(player.get_pitch_rotation().x, player.get_twist_rotation().y, player.get_pitch_rotation().z)
	var collisionResult = move_and_collide(velocity * delta)
	if collisionResult:
		velocity = velocity.bounce(collisionResult.get_normal())
	if area.monitoring == true:
		for a in area.get_overlapping_bodies():
			#// Если это игрок
			if a.get_collision_layer_value(2) == true:
				if a.isInvincible == false:
					a.health -= 1 + GlobalScript.difficulty
					player.hurtAudio.play()
					queue_free()
					#emit_signal("playerDamaged")
					print(a.health)

func _on_life_timer_timeout():
	queue_free()
