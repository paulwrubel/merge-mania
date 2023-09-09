extends MarginContainer

@export var board: Board
var HighScoreLabel: Label
var RestartButton: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	HighScoreLabel = $PanelContainer/MarginContainer/VBoxContainer/HighScoreLabel
	RestartButton = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/RestartButton
	
	board.board_filled.connect(_on_board_filled)
	board.current_level_changed.connect(_on_current_level_changed)

	RestartButton.pressed.connect(_on_restart_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(_delta):
# 	pass


func _on_board_filled():
	visible = true


func _on_current_level_changed(new_current_level: int):
	HighScoreLabel.text = "Highest level achieved: {0}".format([new_current_level])


func _on_restart_button_pressed():
	board.reset_game()
	board.save_game()
	visible = false
