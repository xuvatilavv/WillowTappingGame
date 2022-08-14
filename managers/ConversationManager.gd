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
	file.open("res://text/conversations.json", File.READ)
	var json_raw = file.get_as_text()
	file.close()
	# TODO error checking and stuff
	_conversations = JSON.parse(json_raw).result
	
	if OS.is_debug_build():
		validate()


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


func validate():
	print_debug("Validating conversations...")
	for id in _conversations.keys():
		if typeof(_conversations.get(id)) != TYPE_DICTIONARY:
			push_error("Convo '%s': Not a Dictionary." % id)
			continue

		var dict: Dictionary = _conversations.get(id)
		var errors = []
		match dict.get("type"):
			null:
				errors.append("Missing 'type'.")
			"Dialog":
				errors += validate_Dialog(dict)
			"MultipleChoice":
				errors += validate_MultipleChoice(dict)
			_:
				errors.append("Unknown type: '%s'" % dict.get("type"))
		
		for err in errors:
			push_error("Convo '%s': %s" % [id, err])


func validate_strings(strings: Array) -> Array:
	var errors = []
	
	for string in strings:
		# Doesn't account for keys that match their translation but that should
		# rarely or never happen. Also only checks the current locale.
		if tr(string) == string:
			errors.append(string)

	return errors


func validate_Dialog(dict: Dictionary) -> Array:
	var errors = []

	var strings = dict.get("strings")
	if strings == null:
		errors.append("Missing 'strings'.")
	elif typeof(strings) != TYPE_ARRAY:
		errors.append("Strings is not an Array.")
	else:
		var bad_strings = validate_strings(strings)
		if not bad_strings.empty():
			errors.append("Invalid String IDs: %s" % bad_strings)
	
	# TODO validate image is specified and exists
	
	var next = dict.get("next")
	if next == null:
		errors.append("Missing 'next'.")
	elif _conversations.get(next) == null:
		errors.append("Invalid next convo: '%s'" % next)
	
	return errors


func validate_MultipleChoice(dict: Dictionary) -> Array:
	var errors = []

	var query = dict.get("query")
	if query == null:
		errors.append("Missing 'query'.")
	elif typeof(query) != TYPE_STRING:
		errors.append("Query is not a String.")
	else:
		var bad_strings = validate_strings([query])
		if not bad_strings.empty():
			errors.append("Query is invalid ID: '%s'" % query)
	
	var responses = dict.get("responses")
	if responses == null:
		errors.append("Missing 'responses'.")
	elif typeof(responses) != TYPE_ARRAY:
		errors.append("Responses is not an Array.")
	else:
		var bad_strings = validate_strings(responses)
		if not bad_strings.empty():
			errors.append("Invalid String IDs: %s" % bad_strings)
	
	var branches = dict.get("branches")
	if branches == null:
		errors.append("Missing 'branches'.")
	elif typeof(branches) != TYPE_ARRAY:
		errors.append("Branches is not an Array.")
	else:
		for br in branches:
			if _conversations.get(br) == null:
				errors.append("Invalid branch target: %s" % br)
	
	return errors
