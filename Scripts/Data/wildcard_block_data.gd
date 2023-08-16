class_name WildcardBlockData
extends BlockData

enum CardinalDirection { NORTH, SOUTH, EAST, WEST }

var magnitude: int
var directions: Array[CardinalDirection]

func _init(_magnitude: int, _directions: Array[CardinalDirection]):
	super(BlockData.Type.WILDCARD)
	self.magnitude = _magnitude
	self.directions = _directions.duplicate()
