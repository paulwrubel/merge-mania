extends MarginContainer

signal save_row_button_pressed(save_row_index)
signal close_button_pressed()

@export var save_rows: Array[SaveRow]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# for i in range(5):
		# save_rows[i] = get_node(save_row_paths[d_val])


func _on_close_button_pressed():
	close_button_pressed.emit()


func _on_save_row_pressed(row_index: int):
	save_row_button_pressed.emit(row_index)
