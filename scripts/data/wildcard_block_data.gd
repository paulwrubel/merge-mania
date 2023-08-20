class_name WildcardBlockData
extends BlockData

enum CardinalDirection { NORTH, SOUTH, EAST, WEST }

var magnitude: int
var directions: Array[CardinalDirection]


func _init(magnitude_: int, directions_: Array[CardinalDirection]):
	super(BlockData.Type.WILDCARD)
	self.magnitude = magnitude_
	self.directions = directions_.duplicate()
