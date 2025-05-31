extends Node3D

@export var boss : PackedScene
@export var bossHealthBar : PackedScene
@onready var player = $Player
@onready var noise_audio = $NoiseAudio
@onready var music = $Music
@onready var worldEnvironment = $WorldEnvironment
@onready var worldEnvironmentShader = $WorldEnvironment.environment.sky.sky_material
#@onready var shaderMaterial = $TwistPivot/PitchPivot/Shader.get_active_material(0)

var theBoss
var enemyCounter = 0
var shaderDelta = 0.0

func _ready():
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("EnemyAudio"), 0, false)
	player.piskaPicked = true
	player.toggle_item_visibility()
	player.blackoutScreen.color.a  = 1.0

func _process(delta):
	shaderDelta = shaderDelta + 0.05 * delta
	worldEnvironment.environment.ambient_light_energy = lerp(worldEnvironment.environment.ambient_light_energy, 1.0, shaderDelta * delta)
	worldEnvironmentShader.set_shader_parameter("darkness", lerp(worldEnvironmentShader.get_shader_parameter("darkness"), 1.0, shaderDelta * delta))
	if is_instance_valid(theBoss):
		worldEnvironment.environment.ambient_light_color = Color(worldEnvironment.environment.ambient_light_color.r, 1.0 + theBoss.health / 100.0 - worldEnvironment.environment.ambient_light_color.g, 1.0 + theBoss.health / 100.0 - worldEnvironment.environment.ambient_light_color.b)
		worldEnvironmentShader.set_shader_parameter("glitchness", (100.0 - theBoss.health) / 100.0)
		noise_audio.volume_db = -theBoss.health
		music.volume_db = theBoss.health / 100.0
		music.pitch_scale = clamp((2 * theBoss.health - 100.0) / 100.0, 0.01, 0.9)

func _on_boss_initial_spawn_timer_timeout():
	var bossEnemy = boss.instantiate() as Node3D
	add_child(bossEnemy)
	var bossHealth = bossHealthBar.instantiate() as Node2D
	get_node("Player").get_node("TwistPivot").get_node("PitchPivot").get_node("Camera3D").get_node("MarginContainer").add_child(bossHealth)
	bossEnemy.global_position = Vector3(0.0, 1.0, -6.0)
	theBoss = bossEnemy

func _on_underground_area_body_entered(body):
	if body.get_collision_layer_value(4):
		body.queue_free()
		enemyCounter -= 1
		print("enemy was queue_freed")
		print("enemyCounter = ", enemyCounter)
