class_name DifficultyButton
extends Button

@export var difficulty: Difficulty.Level = Difficulty.Level.NORMAL


# Called when the node enters the scene tree for the first time.
func _ready():
	text = Difficulty.Level.find_key(difficulty).to_lower()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
