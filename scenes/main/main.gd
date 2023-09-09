extends Node2D

signal active_save_index_changed(new_active_save_index)

const GameSelectionScreenScene = preload("res://scenes/game_selection_screen/game_selection_screen.tscn")

const meta_filename = "user://meta.json"

var GameSelectionScreen = null
var Board = null

var active_save_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	try_load_metadata()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Board.active_save_index = active_save_index
	pass


func try_load_metadata() -> bool:
	if not FileAccess.file_exists(meta_filename):
		return false
	
	var meta_file: FileAccess = FileAccess.open(meta_filename, FileAccess.READ)
	var meta_data_raw: String = meta_file.get_line()
	print("loading: ", meta_data_raw)

	var meta_data = JSON.parse_string(meta_data_raw)
	if meta_data == null:
		return false
	
	# current level
	active_save_index = meta_data["active_save_index"]
	$Board.set_active_save_index(active_save_index)

	return true


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_game_selection_button_pressed():
	var gss = GameSelectionScreenScene.instantiate()
	gss.connect("close_button_pressed", _on_game_selection_screen_close_button_pressed)
	gss.connect("save_row_button_pressed", _on_game_selection_screen_save_row_button_pressed)
	GameSelectionScreen = gss
	add_child(gss)

	$Board.is_active = false


func close_game_selection_menu():
	GameSelectionScreen.queue_free()
	GameSelectionScreen = null

	$Board.is_active = true


func _on_game_selection_screen_close_button_pressed():
	close_game_selection_menu()


func _on_game_selection_screen_save_row_button_pressed(save_index):
	active_save_index = save_index
	$Board.set_active_save_index(active_save_index)

	close_game_selection_menu()
