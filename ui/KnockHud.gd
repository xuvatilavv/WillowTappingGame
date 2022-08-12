extends Control


onready var letter_timeout_progress = $LetterTimeoutProgress
onready var word_timeout_progress = $WordTimeoutProgress

onready var letter_timer = $KnockInput/LetterTimer
onready var word_timer = $KnockInput/WordTimer


func _physics_process(_delta):
	# Bad to reach into the scene like this but oh well
	letter_timeout_progress.max_value = letter_timer.wait_time
	letter_timeout_progress.value = letter_timer.time_left
	if letter_timeout_progress.value == 0:
		letter_timeout_progress.value = letter_timeout_progress.max_value
	word_timeout_progress.max_value = word_timer.wait_time
	word_timeout_progress.value = word_timer.time_left
	if word_timeout_progress.value == 0:
		word_timeout_progress.value = word_timeout_progress.max_value


func _on_KnockInput_phrase_changed(phrase: String):
	# TODO choose between c and k more gracefully
	$Label.text = phrase.replace("kh", "ch")
