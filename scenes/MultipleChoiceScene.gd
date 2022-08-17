extends VisibleScene


signal knock
signal choice_made


var knock_count := 0
var has_knocked := false
var can_knock := false


func load_conversation(conv: Dictionary):
	_conv = conv
	$Sprite.texture = load("res://img/" + conv["image"])
	$DialogHud.show_messages([conv["query"]])


func _init():
	var _err = connect("knock", AudioManager, "_on_knock")
	_err = connect("choice_made", SaveManager, "add_choice")


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
	has_knocked = true
	var responses: Array = _conv["responses"]
	var selected = responses[min(responses.size()-1, knock_count)]
	$KnockProgress.visible = false
	emit_signal("choice_made", selected)
	$DialogHud.show_messages([selected])


func _on_DialogHud_messages_finished():
	if not has_knocked:
		can_knock = true
		$KnockProgress.visible = true
		$InputTimer.start()
	else:
		var branches: Array = _conv["branches"]
		var selected = branches[min(branches.size()-1, knock_count)]
		ConversationManager.show(selected)
