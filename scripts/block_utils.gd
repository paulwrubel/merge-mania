extends Node
	
var block_symbols = _build_block_symbols()

var color_progression: Array[Color] = [
	Color.html("#BAFF29"),
	Color.html("#D90DA3"),
	Color.html("#34E4EA"),
	Color.html("#625AFF"),
	Color.html("#D68FD6"),
	Color.html("#CBC0AD"),
	Color.html("#FE5F55"),
	Color.html("#279AF1"),
	Color.html("#FFDD78"),
	Color.html("#B118C8"),
]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

	
func get_formatted_block_text(block: BlockData) -> String:
	match block.type:
		BlockData.Type.POWER:
			var power = (block as PowerBlockData).power
			var symbol_index: int = -1
			for i in range(block_symbols.size()):
				if power >= i * 10 and power - (i * 10) < 10:
					symbol_index = i
					break
			return str(2 ** (power - 10 * symbol_index)) + block_symbols[symbol_index]
		BlockData.Type.WILDCARD:
			return str(2 ** (block as WildcardBlockData).magnitude)
		_:
			return "?"


func get_block_background_color(block: BlockData) -> Color:
	match block.type:
		BlockData.Type.POWER:
			return color_progression[(block as PowerBlockData).power % color_progression.size()]
		BlockData.Type.WILDCARD:
			return color_progression[(block as WildcardBlockData).magnitude % color_progression.size()]
		_:
			return Color.WHITE


func _build_block_symbols() -> PackedStringArray:
	var static_symbols = PackedStringArray([""]) + "kmgtpezyrq".split()
	var dynamic_symbols_level_1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split()
	var dynamic_symbols_level_2: PackedStringArray = []
	for symbol_1 in dynamic_symbols_level_1:
		for symbol_2 in dynamic_symbols_level_1:
			dynamic_symbols_level_2.append(symbol_1 + symbol_2)
			
	return static_symbols + dynamic_symbols_level_1 + dynamic_symbols_level_2