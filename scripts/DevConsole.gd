extends Control

@onready var marginContainer = $MarginContainer
@onready var lineEdit = $MarginContainer/LineEdit
@onready var audioStreamPlayer = $AudioStreamPlayer

var history = []
var historyPosition = 0

func _process(delta):
	if str(lineEdit.text).find("/") != -1:
		for i in range(0, lineEdit.text.length()):
			if lineEdit.text[i] == "/":
				lineEdit.text = lineEdit.text.erase(i, 1)
				break
		lineEdit.release_focus()

func _unhandled_input(event):
	if event.is_action_pressed("dev_console"):
		if marginContainer.visible == false:
			marginContainer.show()
			if is_instance_valid(get_parent().get_node("Pause")):
				get_parent().get_node("Pause").pause()
			else:
				get_tree().paused = true
			focus_line_edit()
		else:
			marginContainer.hide()
			if is_instance_valid(get_parent().get_node("Pause")):
				get_parent().get_node("Pause").pause()
			else:
				get_tree().paused = false
	if Input.is_key_pressed(KEY_UP) && marginContainer.visible == true && historyPosition > 0:
		lineEdit.text = history[historyPosition - 1]
		historyPosition -= 1
	if Input.is_key_pressed(KEY_DOWN) && marginContainer.visible == true && historyPosition < history.size() - 1:
		lineEdit.text = history[historyPosition + 1]
		historyPosition += 1

func focus_line_edit():
	lineEdit.grab_focus()
	lineEdit.set_caret_column(len(lineEdit.text))

func evaluate(command, variable_names = [], variable_values = []) -> void:
	var expression = Expression.new()
	var error = expression.parse(command, variable_names)
	if error != OK:
		push_error(expression.get_error_text())
		return
	var result = expression.execute(variable_values, self)
	if not expression.has_execute_failed():
		print(str(result))

func difficulty(a = null):
	GlobalScript.difficulty = clamp(a, 0, 1)

func bounce(a = null):
	GlobalScript.projectileBounceOption = convert(a, TYPE_BOOL)

func load_scene(a = null):
	get_tree().change_scene_to_file("res://scenes/" + a + ".tscn")

func audio_play(a = null):
	audioStreamPlayer.stream = load("res://audio/" + a + ".mp3")
	audioStreamPlayer.play()
	
func audio_stop(a = null):
	audioStreamPlayer.stop()

func set_timer_time(a = null):
	if get_parent().name == "Player":
		get_parent().timerWatchTime = a

func god_mode(a = null):
	if get_parent().name == "Player":
		if get_parent().isInvincible:
			get_parent().isInvincible = false
		else:
			get_parent().isInvincible = true

func show_solution(a = null):
	if is_instance_valid($"../../SolutionCheat"):
		var s = $"../../SolutionCheat"
		if a == 0:
			s.hide()
		elif a == 1:
			s.show()

func _on_line_edit_text_submitted(new_text):
	lineEdit.release_focus()
	marginContainer.hide()
	if is_instance_valid(get_parent().get_node("Pause")):
		get_parent().get_node("Pause").pause()
	else:
		get_tree().paused = false
	evaluate(lineEdit.text)
	if lineEdit.text.length() > 0 && !history.has(lineEdit.text):
		if history.size() > 7:
			history.remove_at(0)
		history.push_back(lineEdit.text)
		historyPosition = history.size()
	lineEdit.text = ""
