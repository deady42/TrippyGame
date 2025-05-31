extends CharacterBody3D

@onready var player = get_parent().get_node("Player")
@onready var mesh = $MeshInstance3D
@onready var lifeTimer = $LifeTimer

const speed = 15

func _ready():
	velocity = Vector3(-sin(player.get_twist_rotation().y) * cos(player.get_pitch_rotation().x) * speed, sin(player.get_pitch_rotation().x) * speed, -cos(player.get_twist_rotation().y) * cos(player.get_pitch_rotation().x) * speed)
	mesh.rotation = Vector3(player.get_pitch_rotation().x, player.get_twist_rotation().y, player.get_pitch_rotation().z)

func _physics_process(delta):
	if is_instance_valid(player):
		mesh.rotation = Vector3(player.get_pitch_rotation().x, player.get_twist_rotation().y, player.get_pitch_rotation().z)
	var collisionResult = move_and_collide(velocity * delta)
	if collisionResult && GlobalScript.projectileBounceOption == true:
		velocity = velocity.bounce(collisionResult.get_normal())
	elif collisionResult && GlobalScript.projectileBounceOption == false:
		queue_free()
	if global_position.distance_to(player.global_position) > 100:
		queue_free()

func _on_life_timer_timeout():
	queue_free()
