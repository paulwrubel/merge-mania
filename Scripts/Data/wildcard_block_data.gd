class_name WildcardBlockData
extends BlockData

var magnitude: int

func _init(_magnitude: int):
	super(BlockData.Type.WILDCARD)
	self.magnitude = _magnitude
