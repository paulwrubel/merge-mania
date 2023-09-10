class_name SaveRow
extends Button

@export var slot_index: int = 0

var is_empty = true

var _save_text: String = "NEW GAME":
	set(new_save_text):
		if is_inside_tree():
			$MarginContainer/HBoxContainer/SaveLabel.text = new_save_text
		_save_text = new_save_text


# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/HBoxContainer/SlotLabel.text = "{0}".format([slot_index + 1])

	if load_save_and_set_text():
		is_empty = false
	else:
		is_empty = true


func load_save_and_set_text() -> bool:
	var save_filename = "user://save{0}.json".format([slot_index])
	if not FileAccess.file_exists(save_filename):
		return false
	
	var save_file: FileAccess = FileAccess.open(save_filename, FileAccess.READ)
	var save_data_raw: String = save_file.get_line()

	var save_data = JSON.parse_string(save_data_raw)
	if save_data == null:
		return false

	var current_level = save_data["current_level"]
	var difficulty = Difficulty.Level.find_key((save_data["difficulty"] as Difficulty.Level))
	_save_text = "{0} | level {1}".format([difficulty.to_lower(), current_level])
	return true
