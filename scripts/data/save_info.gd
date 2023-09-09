class_name SaveInfo
extends RefCounted

var difficulty: Difficulty.Level
var level: int


func _init(difficulty_: Difficulty.Level, level_: int):
	self.difficulty = difficulty_
	self.level = level_
