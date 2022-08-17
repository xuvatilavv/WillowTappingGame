extends Control


func _ready():
	$CenterContainer2/VBoxContainer/StartButton.grab_focus()


func _on_StartButton_pressed():
	ConversationManager.show("prologue")


func _on_QuitButton_pressed():
	get_tree().quit()
