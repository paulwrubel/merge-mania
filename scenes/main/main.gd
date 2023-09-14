extends Node2D

signal active_save_index_changed(new_active_save_index)

const StatisticsScreenScene = preload("res://scenes/statistics_screen/statistics_screen.tscn")
const SaveSelectionScreenScene = preload("res://scenes/save_selection_screen/save_selection_screen.tscn")
const NewGameScreenScene = preload("res://scenes/new_game_screen/new_game_screen.tscn")

const meta_filename = "user://meta.json"
const menu_transition_time_seconds = 0.2

var metadata: Metadata = null

var SaveSelectionScreen = null
var StatisticsScreen = null
var NewGameScreen = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if not try_load_metadata():
		metadata = Metadata.new()
		metadata.active_save_index = 0
		metadata.statistics = GlobalStatistics.new()
		save_metadata()
	$Board.set_metadata(metadata)
	$Board.board_state_settled.connect(_on_board_state_settled)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func save_metadata():
	var metadata_file: FileAccess = FileAccess.open(meta_filename, FileAccess.WRITE)

	var metadata_raw = metadata.save()

	var metadata_save_string = JSON.stringify(metadata_raw)
	print("saving metadata: ", metadata_save_string)
	metadata_file.store_line(metadata_save_string)


func try_load_metadata() -> bool:
	if not FileAccess.file_exists(meta_filename):
		return false
	
	var metadata_file: FileAccess = FileAccess.open(meta_filename, FileAccess.READ)
	var metadata_string: String = metadata_file.get_line()
	print("loading metadata: ", metadata_string)

	var metadata_raw = JSON.parse_string(metadata_string)
	if metadata_raw == null:
		return false

	metadata = Metadata.load_from_save(metadata_raw)
	$Board.set_metadata(metadata)

	return true


func _on_board_state_settled():
	save_metadata()


func _on_save_selection_button_pressed():
	SaveSelectionScreen = SaveSelectionScreenScene.instantiate()
	SaveSelectionScreen.connect("close_button_pressed", _on_save_selection_screen_close_button_pressed)
	SaveSelectionScreen.connect("save_row_button_pressed", _on_save_selection_screen_save_row_button_pressed)
	add_child(SaveSelectionScreen)

	$Board.is_active = false


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_statistics_button_pressed():
	StatisticsScreen = StatisticsScreenScene.instantiate()
	StatisticsScreen.set_statistics(metadata.statistics, $Board.stats)
	StatisticsScreen.connect("close_button_pressed", _on_statistics_screen_close_button_pressed)
	add_child(StatisticsScreen)

	$Board.is_active = false


func close_save_selection_menu():
	SaveSelectionScreen.queue_free()
	SaveSelectionScreen = null


func close_statistics_screen():
	StatisticsScreen.queue_free()
	StatisticsScreen = null


func close_new_game_menu():
	NewGameScreen.queue_free()
	NewGameScreen = null


func _on_save_selection_screen_close_button_pressed():
	close_save_selection_menu()
	$Board.is_active = true


func _on_statistics_screen_close_button_pressed():
	close_statistics_screen()
	$Board.is_active = true


func _on_save_selection_screen_save_row_button_pressed(save_index: int, save_slot_is_empty: bool):
	metadata.active_save_index = save_index
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
		$Board.set_metadata(metadata)
		save_metadata()

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
	$Board.set_metadata(metadata)
	save_metadata()

	close_new_game_menu()
	$Board.is_active = true
