extends Control


func _ready():
	if SaveManager.has_save():
		$CenterContainer2/VBoxContainer/ContinueButton.disabled = false
		$CenterContainer2/VBoxContainer/ContinueButton.grab_focus()
	else:
		$CenterContainer2/VBoxContainer/ContinueButton.disabled = true
		$CenterContainer2/VBoxContainer/StartButton.grab_focus()


func _on_ContinueButton_pressed():
	SaveManager.load_data()
	ConversationManager.show(SaveManager.get_current())


func _on_StartButton_pressed():
	ConversationManager.show(SaveManager.get_current())


func _on_QuitButton_pressed():
	get_tree().quit()
