extends MarginContainer

signal save_row_button_pressed(save_row_index)
signal close_button_pressed()

@export var save_rows: Array[SaveRow]


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(save_rows.size()):
		var save_row = save_rows[i]
		save_row.pressed.connect(_on_save_row_pressed.bind(i))


func _on_close_button_pressed():
	close_button_pressed.emit()


func _on_save_row_pressed(row_index: int):
	var save_row = save_rows[row_index]
	save_row_button_pressed.emit(row_index, save_row.is_empty)
