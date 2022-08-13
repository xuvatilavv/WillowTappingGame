extends Control


func _on_StartButton_pressed():
	ConversationManager.show("prologue")


func _on_QuitButton_pressed():
	get_tree().quit()
