extends VisibleScene


signal knock
signal choice_made


var knock_count := 0
var has_knocked := false
var can_knock := false
var choice


func load_conversation(conv: Dictionary):
	_conv = conv
	$Sprite.texture = load("res://img/" + conv["image"])
	$DialogHud.show_messages(conv["intro"])


func _init():
	var _err = connect("knock", AudioManager, "_on_knock")
	_err = connect("choice_made", SaveManager, "set_flag")


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
	$KnockProgress.visible = false

	var possible: Array = _conv["choices"]
	var selected = possible[min(possible.size()-1, knock_count)]

	if typeof(selected) == TYPE_ARRAY:
		for alt in selected:
			var requires = alt.get("requires")
			if requires == null or requires.empty():
				choice = alt
				break

			var requirements_met = true
			for flag in requires:
				if not SaveManager.is_flag_set(flag):
					requirements_met = false
					break

			if requirements_met:
				choice = alt
				break
	else:
		choice = selected
	
	var facts = choice.get("facts")
	if facts != null:
		for fact in facts:
			SaveManager.set_flag(fact)

	emit_signal("choice_made", choice["response"])
	$DialogHud.show_messages([choice["response"]])


func _on_DialogHud_messages_finished():
	if not has_knocked:
		can_knock = true
		$KnockProgress.visible = true
		$InputTimer.start()
	else:
		ConversationManager.show(choice["next"])
