class_name WildcardBlockData
extends BlockData

enum CardinalDirection { NORTH, SOUTH, EAST, WEST }

var magnitude: int
var directions: Array


func _init(magnitude_: int, directions_: Array):
	super(BlockData.Type.WILDCARD)
	self.magnitude = magnitude_
	self.directions = directions_.duplicate()


func save() -> Dictionary:
	return {
		"type": Type.WILDCARD,
		"magnitude": magnitude,
		"directions": directions.duplicate(),
	}