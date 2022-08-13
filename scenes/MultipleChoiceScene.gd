extends VisibleScene


signal knock


var knock_count := 0
var can_knock := true


func load_conversation(conv: Dictionary):
	_conv = conv
	$Sprite.texture = load("res://img/" + conv["image"])
	$DialogHud.show_messages([conv["query"]])
	$InputTimer.start()


func _init():
	var _err = connect("knock", AudioManager, "_on_knock")


func _physics_process(_delta):
	$KnockProgress.max_value = $InputTimer.wait_time
	$KnockProgress.value = $InputTimer.time_left


func _input(event):
	if can_knock and event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		knock_count += 1
		emit_signal("knock")


func _on_InputTimer_timeout():
	can_knock = false
	var responses: Array = _conv["responses"]
	var selected = responses[min(responses.size()-1, knock_count)]
	$DialogHud.show_messages([selected])


func _on_DialogHud_messages_finished():
	var branches: Array = _conv["branches"]
	var selected = branches[min(branches.size()-1, knock_count)]
	ConversationManager.show(selected)
