class_name BlockData
extends RefCounted

enum Type { POWER, WILDCARD }

var type: Type


func _init(type_: Type):
	self.type = type_

static func load_from_save(data: Dictionary) -> BlockData:
	match data["type"] as Type:
		Type.POWER:
			return PowerBlockData.new(data["power"])
		Type.WILDCARD:
			return WildcardBlockData.new(
				data["magnitude"], 
				data["directions"],
			)
		_:
			print("unknown block type: ", data["type"])
			return null