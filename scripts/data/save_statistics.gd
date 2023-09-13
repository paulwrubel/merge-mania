class_name SaveStatistics
extends RefCounted

var merge_count: int = 0 
var max_merge: int = 0
var max_chain: int = 0
var blocks_snapped: int = 0

static func load_from_save(data: Dictionary) -> SaveStatistics:
	var stats = SaveStatistics.new()
	stats.merge_count = data["merge_count"]
	stats.max_merge = data["max_merge"]
	stats.max_chain = data["max_chain"]
	stats.blocks_snapped = data["blocks_snapped"]
	return stats

func save() -> Dictionary:
	return {
		"merge_count": merge_count,
		"max_merge": max_merge, 
		"max_chain": max_chain, 
		"blocks_snapped": blocks_snapped, 
	}