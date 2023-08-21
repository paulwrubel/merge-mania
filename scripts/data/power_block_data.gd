class_name PowerBlockData
extends BlockData

var power: int


func _init(power_: int):
	super(BlockData.Type.POWER)
	self.power = power_


func save() -> Dictionary:
	return {
		"type": Type.POWER,
		"power": power,
	}