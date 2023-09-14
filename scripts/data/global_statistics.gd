class_name GlobalStatistics
extends RefCounted

var merge_count: int = 0 
var max_level: Dictionary = {
	Difficulty.Level.TRIVIAL: 0,
	Difficulty.Level.EASY: 0,
	Difficulty.Level.NORMAL: 0,
	Difficulty.Level.HARD: 0,
	Difficulty.Level.EXPERT: 0,
}
# var max_merge: int = 0
# var max_chain: int = 0
# var blocks_snapped: int = 0

static func load_from_save(data: Dictionary) -> GlobalStatistics:
	var stats = GlobalStatistics.new()
	stats.merge_count = data["merge_count"]
	stats.max_level = {}
	for key in data["max_level"].keys():
		var fstring = "{0}"
		match key as Difficulty.Level:
			Difficulty.Level.TRIVIAL:
				stats.max_level[Difficulty.Level.TRIVIAL] = data["max_level"][fstring.format([Difficulty.Level.TRIVIAL])]
			Difficulty.Level.EASY:
				stats.max_level[Difficulty.Level.EASY] = data["max_level"][fstring.format([Difficulty.Level.EASY])]
			Difficulty.Level.NORMAL:
				stats.max_level[Difficulty.Level.NORMAL] = data["max_level"][fstring.format([Difficulty.Level.NORMAL])]
			Difficulty.Level.HARD:
				stats.max_level[Difficulty.Level.HARD] = data["max_level"][fstring.format([Difficulty.Level.HARD])]
			Difficulty.Level.EXPERT:
				stats.max_level[Difficulty.Level.EXPERT] = data["max_level"][fstring.format([Difficulty.Level.EXPERT])]
	# stats.max_merge = data["max_merge"]
	# stats.max_chain = data["max_chain"]
	# stats.blocks_snapped = data["blocks_snapped"]
	return stats

func save() -> Dictionary:
	return {
		"merge_count": merge_count,
		"max_level": max_level, 
		# "max_chain": max_chain, 
		# "blocks_snapped": blocks_snapped, 
	}
