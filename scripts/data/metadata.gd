class_name Metadata
extends RefCounted

var active_save_index: int = 0
var statistics: GlobalStatistics = null

static func load_from_save(data: Dictionary) -> Metadata:
	var metadata = Metadata.new()
	metadata.active_save_index = data["active_save_index"]
	metadata.statistics = GlobalStatistics.load_from_save(data["statistics"])
	return metadata

func save() -> Dictionary:
	return {
		"active_save_index": active_save_index,
		"statistics": statistics.save(),
	}