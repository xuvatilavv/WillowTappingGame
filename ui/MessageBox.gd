extends CanvasLayer


onready var messagebox: Container = $MarginContainer
onready var label: PagedRichTextLabel = $MarginContainer/Panel/RichTextLabel

var _messages: Array = []
var _me_regex = RegEx.new()

signal messages_started
signal messages_finished
signal message_advanced

const page_delimiter := "|"


func _ready():
	var _err = connect("message_advanced", AudioManager, "_on_message_advanced")
	label.text = ""
	_me_regex.compile("^(PROLOGUE|THOUGHTS|INTERLUDE|EPILOGUE)")


func show_messages(messages: Array):
	if messages.empty():
		push_warning("tried to show empty array of messages")
		return
	emit_signal("messages_started")
	_messages = messages.duplicate()
	label.text = ""
	_advance_message()


func _advance_message():
	if not label.text.empty() and label.advance():
		return
	if _messages.empty():
		emit_signal("messages_finished")
		return

	label.reset()
	var new = _messages.pop_front()

	#HACK select alt string based on flags if specified
	if typeof(new) == TYPE_ARRAY:
		for alt in new:
			var requires = alt.get("requires")
			if requires == null or requires.empty():
				_messages = alt["strings"] + _messages
				break
			var requirements_met = true
			for flag in requires:
				if not SaveManager.is_flag_set(flag):
					requirements_met = false
					break
			if requirements_met:
				_messages = alt["strings"] + _messages
				break
		new = _messages.pop_front()

	# Split pages by delimiter character
	var new_split = Array(tr(new).split(page_delimiter))
	label.text = new_split.pop_front().strip_edges()
	if not new_split.empty():
		# Add any text after the first page to the front of the message queue.
		_messages = new_split + _messages
	#HACK
	if new.begins_with("INTERVIEWER"):
		$SpeakerContainer/Panel/Label.text = "Interviewer"
	elif _me_regex.search(new):
		$SpeakerContainer/Panel/Label.text = "Me"
	
	if label.text == "":
		_advance_message()


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("message_advanced")
		get_tree().set_input_as_handled()
		_advance_message()
