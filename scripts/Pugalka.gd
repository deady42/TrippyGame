class_name Pugalka
extends CharacterBody3D

@export var player_path : NodePath
@onready var mesh = $MeshInstance3D
@onready var timer = $Timer
@onready var audio = $AudioStreamPlayer3D
@onready var appearanceAudio = $Appearance

var player = null
const speed = 130

func _ready():
	player = get_node(player_path)

func _process(_delta):
	if timer.is_stopped() && audio.playing == false && is_visible_in_tree():
		audio.play()
		timer.wait_time = randf_range(2, 5)
		timer.start()

func _physics_process(delta):
	if is_instance_valid(player) && is_visible_in_tree():
		look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP, true)
		velocity = (player.global_position - global_transform.origin).normalized() * speed * global_position.distance_to(player.global_position) * delta
	move_and_slide()
	
func pugalka_appear_toggle():
	if is_visible_in_tree() == false:
		appearanceAudio.play()
		show()
	else:
		hide()


func _on_area_3d_body_entered(body):
	if body.get_collision_layer_value(2) == true && body.isInvincible == false:
		body.health = 0

func _on_player_player_progress_bar_timeout():
	pugalka_appear_toggle()
