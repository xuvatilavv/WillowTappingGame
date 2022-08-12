extends CanvasLayer


onready var messagebox: Container = $MarginContainer
onready var label: PagedRichTextLabel = $MarginContainer/NinePatchRect/RichTextLabel

var _messages: Array = []

signal messages_started
signal messages_finished


func _ready():
	messagebox.visible = false
	label.text = ""


func show_messages(messages: Array):
	if messages.empty():
		push_warning("tried to show empty array of messages")
		return
	emit_signal("messages_started")
	_messages = messages.duplicate()
	messagebox.visible = true
	_advance_message()


func _advance_message():
	if not label.text.empty() and label.advance():
		return
	if _messages.empty():
		label.text = ""
		messagebox.visible = false
		emit_signal("messages_finished")
		return
	label.text = tr(_messages.pop_front())


func _unhandled_input(event):
	if messagebox.visible and event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		_advance_message()


func on_TextItem_read(messages: Array):
	if not messagebox.visible:
		show_messages(messages)
