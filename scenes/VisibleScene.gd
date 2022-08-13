class_name VisibleScene
extends Node2D


var _conv: Dictionary


func _ready():
	load_conversation(ConversationManager.current_conversation)


func load_conversation(conv: Dictionary) -> void:
	# Override this in inherited classes
	push_warning("Called base load_conversation on " + name)


func _end_scene():
	ConversationManager.show(_conv["next"])
