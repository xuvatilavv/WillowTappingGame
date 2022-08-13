extends CanvasLayer


onready var messagebox: Container = $MarginContainer
onready var label: PagedRichTextLabel = $MarginContainer/Panel/RichTextLabel

var _messages: Array = []

signal messages_started
signal messages_finished
signal message_advanced


func _ready():
	var _err = connect("message_advanced", AudioManager, "_on_message_advanced")
	label.text = ""


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
		label.text = ""
		emit_signal("messages_finished")
		return
	label.text = tr(_messages.pop_front())


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("message_advanced")
		get_tree().set_input_as_handled()
		_advance_message()
