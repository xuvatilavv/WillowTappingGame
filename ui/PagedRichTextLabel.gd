class_name PagedRichTextLabel
extends RichTextLabel


onready var scroll: VScrollBar = get_child(0)


# Returns true if text was scrolled, or false if there is no more text to show
func advance() -> bool:
	if scroll.max_value <= scroll.value + scroll.page:
		scroll.value = 0
		return false
	scroll.value += scroll.page
	return true


func _process(_delta):
	if scroll.max_value == scroll.value + int(scroll.page * 1.5):
		text += "\n"	
