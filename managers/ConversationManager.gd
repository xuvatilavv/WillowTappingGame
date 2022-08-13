extends Node


enum SceneType {
	Dialog,
	KnockCode,
	MultipleChoice,
}


var _DialogScene = preload("res://scenes/DialogScene.tscn")
var _KnockCodeScene = preload("res://scenes/KnockCodeScene.tscn")
var _MultipleChoiceScene = preload("res://scenes/MultipleChoiceScene.tscn")

var current_conversation: Dictionary = {}
var _conversations: Dictionary = {}


func _init():
	var file = File.new()
	file.open("res://scenes/conversations.json", File.READ)
	var json_raw = file.get_as_text()
	file.close()
	# TODO error checking and stuff
	_conversations = JSON.parse(json_raw).result
	
	


func show(conversation_name: String):
	if (conversation_name == "END_GAME"):
		print_debug("TODO: END GAME GOES HERE")
		return
	var def = _conversations.get(conversation_name)
	if def == null:
		push_error("Conversation not defined: " + conversation_name)
		return
	
	current_conversation = def
	match def["type"]:
		"Dialog":
			var _err = get_tree().change_scene_to(_DialogScene)
		"KnockCode":
			var _err = get_tree().change_scene_to(_KnockCodeScene)
		"MultipleChoice":
			var _err = get_tree().change_scene_to(_MultipleChoiceScene)
