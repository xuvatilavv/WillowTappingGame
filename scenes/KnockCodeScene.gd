extends VisibleScene

func load_conversation(conv: Dictionary):
	_conv = conv
	$Sprite.texture = load("res://img/" + conv["image"])
	# TODO
