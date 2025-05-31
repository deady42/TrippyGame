extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var target = $"../Marker3D"

var direction = Vector3()
var speed = 1

func _ready():
	set_physics_process(false)
	call_deferred("dump_first_physics_frame")

func _physics_process(delta):
	if is_instance_valid(target):
		nav.target_position = target.global_position
		var next_position = nav.get_next_path_position()
		#look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP, true)
		direction = (next_position - global_position).normalized()
		velocity = velocity.lerp(direction * speed, 10 * delta)
		velocity.y = 0
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()
func dump_first_physics_frame() -> void:
	#wait until just before the second physics_frame is ready to go, then
		#re-enable _physics_process()
	await get_tree().physics_frame
	set_physics_process(true)
