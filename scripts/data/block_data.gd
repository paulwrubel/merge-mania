class_name BlockData
extends RefCounted

enum Type { POWER, WILDCARD }

var type: Type


func _init(type_: Type):
	self.type = type_
