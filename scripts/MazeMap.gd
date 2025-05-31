extends Node2D

@onready var playerMarker = $PlayerMarker
@onready var piskaMarker = $PiskaMarker
@onready var mapOpenAudio = $MapOpenAudio
@onready var player = $".."
@onready var piska = $"../../Piska"

func _process(delta):
	if Input.is_action_just_pressed("map_toggle") && visible:
		mapOpenAudio.play()
	
	if !is_visible_in_tree() && !is_instance_valid(piska):
		piskaMarker.hide()
	
	if is_visible_in_tree() && is_instance_valid(player):
		set_player_marker_position(Vector2(-(player.global_position.x + 78.0)*5 + 390.0, -(player.global_position.z + 78.0)*5 + 390.0))

func set_player_marker_position(pos = Vector2.ZERO):
	playerMarker.position = pos
