extends Node

signal conversation_reached

enum SceneType {
	Dialog,
	KnockCode,
	MultipleChoice,
}


var _MainMenuScene = preload("res://ui/MainMenu.tscn")
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
	_conversations = JSON.parse(json_raw).result
	
	if OS.is_debug_build():
		validate()
	
	var _err = connect("conversation_reached", SaveManager, "set_current")


func show(conversation_name: String):
	if (conversation_name == "END_GAME"):
		get_tree().change_scene_to(_MainMenuScene)
		return
	var def = _conversations.get(conversation_name)
	if def == null:
		push_error("Conversation not defined: " + conversation_name)
		return
	
	emit_signal("conversation_reached", conversation_name)
	current_conversation = def
	match def["type"]:
		"Dialog":
			var _err = get_tree().change_scene_to(_DialogScene)
		"KnockInput":
			var _err = get_tree().change_scene_to(_KnockCodeScene)
		"Choice":
			var _err = get_tree().change_scene_to(_MultipleChoiceScene)
		_:
			push_error("Unknown conversation type: %s" % def["type "])


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
				errors += validate_DialogType(dict)
			"Choice":
				errors += validate_ChoiceType(dict)
			"KnockInput":
				errors += validate_KnockInputType(dict)
			"KnockOutput":
				errors += validate_KnockOutputType(dict)
			_:
				errors.append("Unknown type: '%s'" % dict.get("type"))
		
		for err in errors:
			push_error("Convo '%s': %s" % [id, err])


func validate_strings(strings: Array) -> Array:
	var errors = []
	
	for string in strings:
	# Doesn't account for keys that match their translation but that should
	# rarely or never happen. Also only checks the current locale.
		if typeof(string) == TYPE_STRING:
			if tr(string) == string:
				errors.append(string)
		elif typeof(string) == TYPE_ARRAY:
			#TODO validate alternate strings (keys: response, strings)
			pass
		else:
			errors.append("String is not String or alt Array.")

	return errors


func validate_intro(dict: Dictionary) -> Array:
	var errors = []

	var strings = dict.get("intro")
	if strings == null:
		errors.append("Missing 'intro'.")
	elif typeof(strings) != TYPE_ARRAY:
		errors.append("Intro is not an Array.")
	else:
		var bad_strings = validate_strings(strings)
		if not bad_strings.empty():
			errors.append("Invalid String IDs: %s" % bad_strings)
	
	return errors


func validate_next(dict: Dictionary) -> Array:
	var errors = []

	var next = dict.get("next")
	if next == null:
		errors.append("Missing 'next'.")
	elif _conversations.get(next) == null:
		errors.append("Invalid next convo: '%s'" % next)
	
	return errors


func validate_choice_single(dict: Dictionary) -> Array:
	var errors = []
	
	# optional
	var requires = dict.get("requires")
	if requires != null:
		if typeof(requires) != TYPE_ARRAY:
			errors.append("Requires is not an Array.")
		else:
			#TODO can be a string ID or Fact from another conversation
			pass

	# optional	
	var response = dict.get("response")
	if response != null:
		if typeof(response) != TYPE_STRING:
			errors.append("Response is not a String.")
		else:
			var bad_strings = validate_strings([response])
			if not bad_strings.empty():
				errors.append("Invalid String IDs: %s" % bad_strings)
	
	# optional
	var facts = dict.get("facts")
	#TODO no real limitations here
	
	errors += validate_next(dict)

	return errors


func validate_choices(dict: Dictionary) -> Array:
	var errors = []
	
	var choices = dict.get("choices")
	if choices == null:
		errors.append("Missing 'choices'.")
	elif typeof(choices) != TYPE_ARRAY:
		errors.append("Choices is not an Array.")
	else:
		for choice in choices:
			if typeof(choice) == TYPE_DICTIONARY:
				errors += validate_choice_single(choice)
			elif typeof(choice) == TYPE_ARRAY:
				for alt in choice:
					errors += validate_choice_single(alt)
			else:
				errors.append("Choice is neither a Dictionary nor Array.")

	return errors


func validate_message(dict: Dictionary) -> Array:
	var errors = []
	
	var message = dict.get("message")
	if message == null:
		errors.append("Missing 'message'.")
	else:
		var bad_strings = validate_strings([message])
		if not bad_strings.empty():
			errors.append("Invalid String IDs: %s" % bad_strings)
	
	return errors


func validate_expected_single(dict: Dictionary) -> Array:
	var errors = []
	
	var response = dict.get("response")
	if response == null:
		errors.append("Missing 'response'.")
	else:
		var bad_strings = validate_strings([ response ])
		if not bad_strings.empty():
			errors.append("Invalid String IDs: %s" % bad_strings)

	var facts = dict.get("facts")
	#TODO
	
	errors += validate_next(dict)
	
	return errors


func validate_expected(dict: Dictionary) -> Array:
	var errors = []
	
	var expected = dict.get("expected")
	if expected == null:
		errors.append("Missing 'expected'.")
	elif typeof(expected) != TYPE_DICTIONARY:
		errors.append("Expected is not a Dictionary.")
	else:
		var default =  expected.get("_")
		if default == null:
			errors.append("Missing '_' (default).")
		else:
			errors += validate_expected_single(default)
		
		var keys = expected.keys()
		var default_idx = keys.find("_")
		keys.remove(default_idx)
		for key in keys:
			var bad_strings = validate_strings([key])
			if not bad_strings.empty():
				errors.append("Invalid String ID as key: %s" % key)
			errors += validate_expected_single(expected[key])

	return errors


func validate_DialogType(dict: Dictionary) -> Array:
	var errors = []

	errors += validate_intro(dict)
	errors += validate_next(dict)
	# TODO validate image is specified and exists
	
	return errors


func validate_ChoiceType(dict: Dictionary) -> Array:
	var errors = []
	
	errors += validate_intro(dict)
	errors += validate_choices(dict)
	
	return errors


func validate_KnockOutputType(dict: Dictionary) -> Array:
	var errors = []
	
	errors += validate_intro(dict)
	errors += validate_message(dict)

	return errors


func validate_KnockInputType(dict: Dictionary) -> Array:
	var errors = []
	
	errors += validate_intro(dict)
	errors += validate_expected(dict)
	
	return errors
