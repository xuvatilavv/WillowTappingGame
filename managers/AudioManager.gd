extends Node


var knocks = [
	preload("res://sound/knock1.wav"),
	preload("res://sound/knock2.wav"),
	preload("res://sound/knock3.wav"),
	preload("res://sound/knock4.wav"),
	preload("res://sound/knock5.wav"),
]

var message_advance = preload("res://sound/messagebox.wav")


func _on_knock():
	$EffectPlayer.stream = knocks[rand_range(0, knocks.size()-1)]
	$EffectPlayer.play()


func _on_message_advanced():
	$EffectPlayer.stream = message_advance
	$EffectPlayer.play()
