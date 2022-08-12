extends Control


signal knock
signal phrase_changed
signal letter_failed

const code := [
	['A','B','K','D','E'], # TODO decide how to represent C/K
	['F','G','H','I','J'],
	['L','M','N','O','P'],
	['Q','R','S','T','U'],
	['V','W','X','Y','Z'],
]


var knock_count := 0
var knock_count_row := 0

onready var letter_timer: Timer = $LetterTimer
onready var word_timer: Timer = $WordTimer


var phrase := ""


func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		knock()


func knock():
	word_timer.stop()
	emit_signal("knock")
	knock_count += 1
	if knock_count > 5:
		emit_signal("letter_failed")
		knock_count = 0
		knock_count_row = 0
		letter_timer.stop()
		return
	letter_timer.start()


func _on_LetterTimer_timeout():
	if knock_count <= 0:
		knock_count_row = 0
		knock_count = 0
		emit_signal("letter_failed")
		return
	
	if knock_count_row > 0:
		phrase += code[knock_count_row-1][knock_count-1]
		knock_count_row = 0
		knock_count = 0
		emit_signal("phrase_changed", phrase)
		word_timer.start()
	else:
		knock_count_row = knock_count
		knock_count = 0
		letter_timer.start()


func _on_WordTimer_timeout():
	phrase += " "
	emit_signal("phrase_changed", phrase)
