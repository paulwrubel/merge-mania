class_name LevelLabel
extends Label

@export var board: Board

# Called when the node enters the scene tree for the first time.
func _ready():
	update_text_from_level(board.current_level)
	board.current_level_changed.connect(_on_current_level_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func update_text_from_level(level: int):
	text = "Level {0}".format([level])


func _on_current_level_changed(new_current_level: int):
	update_text_from_level(new_current_level)
