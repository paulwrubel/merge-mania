class_name BlockData
extends RefCounted

enum Type {POWER, WILDCARD}

var type: Type

func _init(_type: Type):
	self.type = _type
