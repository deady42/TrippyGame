extends Node

var difficulty = 0
var currentDifficulty = 0
var icon = preload("res://icon.png")
var iconZms3Mode = preload("res://icon_zms3_mode.png")
var projectileBounceOption = false
var mouseSensitivityMult = 100.0
var masterAudioRegulatorRotationDegrees = 90.0
var savedTimerWatchTime = 600
var symbols = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	get_tree().set_auto_accept_quit(false)

func _process(_delta):
	if currentDifficulty != difficulty:
		if difficulty == 0:
			DisplayServer.window_set_title("happy_emoji_3")
			DisplayServer.set_icon(icon)
		else:
			DisplayServer.set_icon(iconZms3Mode)
		currentDifficulty = difficulty
	
	if difficulty >= 1:
		if OS.has_environment("USERNAME"):
			DisplayServer.window_set_title("A terrifying fate of " + OS.get_environment("USERNAME"))
		else:
			var rand_word = ""
			for i in range(9):
				rand_word += symbols.pick_random()
			DisplayServer.window_set_title("A terrifying fate of " + rand_word)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if difficulty >= 1 and get_tree().current_scene.name != "Diploma":
			pass
		else:
			get_tree().quit() # default behavior
