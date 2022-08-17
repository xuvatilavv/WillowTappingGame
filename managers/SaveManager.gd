extends Node


var _data := {
	"current": "prologue",
	"chose": [],
}

const save_path := "user://savedata.json"


func add_choice(id: String) -> void:
	if _data["chose"].count(id) > 0:
		push_warning("Tried to save choice ID but it's already present in the save: %s" % id)
		return
	_data["chose"].append(id)
	save_data()


func get_choices() -> Array:
	return _data["chose"]


func set_current(id: String) -> void:
	print_debug("updating current to %s" % id)
	_data["current"] = id
	save_data()


func get_current() -> String:
	return _data["current"]


func save_data() -> void:
	var savedata = JSON.print(_data)
	var file = File.new()
	file.open(save_path, File.WRITE)
	file.store_string(savedata)
	file.close()


func load_data() -> void:
	var file = File.new()
	if not file.file_exists(save_path):
		push_warning("No save file to load.")
		return
	file.open(save_path, File.READ)
	var savedata = file.get_as_text()
	file.close()
	var result = JSON.parse(savedata).result
	if typeof(result) != TYPE_DICTIONARY:
		push_error("Could not parse save file.")
		return
	_data = result


func has_save() -> bool:
	var file = File.new()
	return file.file_exists(save_path)
