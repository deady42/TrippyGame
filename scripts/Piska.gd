class_name Piska
extends StaticBody3D

signal piskaPicked

@export var player_path : NodePath

var player = null

func _ready():
	player = get_node(player_path)

func _process(_delta):
	if is_instance_valid(player):
		look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP, true)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("PiskaTheme"), 0 - clamp(global_position.distance_to(player.global_position)/4, 0, 100))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("CalmMusic"), -100 + clamp(global_position.distance_to(player.global_position)*4, 0, 100))

func _on_area_3d_body_entered(body):
	if body.get_collision_layer_value(2) == true && is_instance_valid(player):
		emit_signal("piskaPicked")
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("EnemyAudio"), 0, true)
		queue_free()
