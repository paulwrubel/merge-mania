class_name PowerBlockData
extends BlockData

var power: int


func _init(power_: int):
	super(BlockData.Type.POWER)
	self.power = power_
