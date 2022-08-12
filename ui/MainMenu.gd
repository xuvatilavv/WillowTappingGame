extends Control


func _on_StartButton_pressed():
	ConversationManager.show("test_dialog")


func _on_QuitButton_pressed():
	get_tree().quit()
