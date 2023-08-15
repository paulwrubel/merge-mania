class_name PowerBlockData
extends BlockData

var power: int

func _init(_power: int):
	super(BlockData.Type.POWER)
	self.power = _power
