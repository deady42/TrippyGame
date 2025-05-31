extends Node2D

@onready var characterBody = $SubViewport/CharacterBody2D
@onready var textureProgressBar = $TextureProgressBar

func _process(_delta):
	if characterBody.position.y <= -64.0:
		characterBody.position = Vector2.ZERO
	characterBody.velocity = Vector2(1, -0.5) * 256.0
	characterBody.move_and_slide()
	#textureProgressBar.value = get_parent().get_parent().get_node("Boss").health
	textureProgressBar.value = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Boss").health
	#position = Vector2(-(252/2)-576 - 200, -16.0)
