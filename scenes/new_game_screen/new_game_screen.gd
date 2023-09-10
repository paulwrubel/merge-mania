extends MarginContainer

signal difficulty_button_pressed(difficulty)
signal close_button_pressed()
signal back_button_pressed()

@export var difficulty_buttons: Array[DifficultyButton]


# Called when the node enters the scene tree for the first time.
func _ready():
	for db in difficulty_buttons:
		db.pressed.connect(_on_difficulty_button_pressed.bind(db.difficulty))


func _on_close_button_pressed():
	close_button_pressed.emit()


func _on_back_button_pressed():
	back_button_pressed.emit()


func _on_difficulty_button_pressed(difficulty: Difficulty.Level):
	difficulty_button_pressed.emit(difficulty)
