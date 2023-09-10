extends Node2D

signal active_save_index_changed(new_active_save_index)

const SaveSelectionScreenScene = preload("res://scenes/save_selection_screen/save_selection_screen.tscn")
const NewGameScreenScene = preload("res://scenes/new_game_screen/new_game_screen.tscn")

const meta_filename = "user://meta.json"
const menu_transition_time_seconds = 0.2

var SaveSelectionScreen = null
var NewGameScreen = null

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


func _on_save_selection_button_pressed():
	SaveSelectionScreen = SaveSelectionScreenScene.instantiate()
	SaveSelectionScreen.connect("close_button_pressed", _on_save_selection_screen_close_button_pressed)
	SaveSelectionScreen.connect("save_row_button_pressed", _on_save_selection_screen_save_row_button_pressed)
	add_child(SaveSelectionScreen)

	$Board.is_active = false


func close_save_selection_menu():
	SaveSelectionScreen.queue_free()
	SaveSelectionScreen = null


func close_new_game_menu():
	NewGameScreen.queue_free()
	NewGameScreen = null


func _on_save_selection_screen_close_button_pressed():
	close_save_selection_menu()
	$Board.is_active = true


func _on_save_selection_screen_save_row_button_pressed(save_index: int, save_slot_is_empty: bool):
	active_save_index = save_index
	if save_slot_is_empty:
		# initialize the new game screen
		NewGameScreen = NewGameScreenScene.instantiate()
		NewGameScreen.position.x = $GUI.size.x
		NewGameScreen.connect("close_button_pressed", _on_new_game_screen_close_button_pressed)
		NewGameScreen.connect("back_button_pressed", _on_new_game_screen_back_button_pressed)
		NewGameScreen.connect("difficulty_button_pressed", _on_new_game_screen_difficulty_button_pressed)
		add_child(NewGameScreen)

		# animate the new game screen moving left (into view)
		# and the save selection screen moving left (out of view)
		var tween = create_tween()
		tween.tween_property(NewGameScreen, "position:x", 0, menu_transition_time_seconds)
		tween.parallel().tween_property(SaveSelectionScreen, "position:x", -$GUI.size.x, menu_transition_time_seconds)
		var on_finish = func():
			close_save_selection_menu()
			$Board.is_active = false
		tween.tween_callback(on_finish)
	else:
		# select the save and close the menu
		$Board.set_active_save_index(active_save_index)

		close_save_selection_menu()
		$Board.is_active = true


func _on_new_game_screen_close_button_pressed():
	close_new_game_menu()
	$Board.is_active = true


func _on_new_game_screen_back_button_pressed():
	# initialize the save selection screen
	SaveSelectionScreen = SaveSelectionScreenScene.instantiate()
	SaveSelectionScreen.position.x = -$GUI.size.x
	SaveSelectionScreen.connect("close_button_pressed", _on_save_selection_screen_close_button_pressed)
	SaveSelectionScreen.connect("save_row_button_pressed", _on_save_selection_screen_save_row_button_pressed)
	add_child(SaveSelectionScreen)

	# animate the new game screen moving right (out of view)
	# and the save selection screen moving right (into view)
	var tween = create_tween()
	tween.tween_property(NewGameScreen, "position:x", $GUI.size.x, menu_transition_time_seconds)
	tween.parallel().tween_property(SaveSelectionScreen, "position:x", 0, menu_transition_time_seconds)
	var on_finish = func():
		close_new_game_menu()
		$Board.is_active = false
	tween.tween_callback(on_finish)


func _on_new_game_screen_difficulty_button_pressed(difficulty: Difficulty.Level):
	# select difficulty and close the menu
	$Board.set_difficulty(difficulty)
	$Board.set_active_save_index(active_save_index)

	close_new_game_menu()
	$Board.is_active = true
