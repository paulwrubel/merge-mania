class_name ColorUtils

static func get_contrast_ratio(color_1: Color, color_2: Color) -> float:
	var lum_1 = color_1.srgb_to_linear().get_luminance()
	var lum_2 = color_2.srgb_to_linear().get_luminance()
	
	return (maxf(lum_1, lum_2) + 0.05) / (minf(lum_1, lum_2) + 0.05)
	
static func get_highest_contrast_to(subject: Color, options: Array[Color]) -> Color:
	var max_ratio = 0
	var max_color = null
	for option in options:
		var current_ratio = get_contrast_ratio(subject, option)
		if current_ratio > max_ratio:
			max_ratio = current_ratio
			max_color = option
	return max_color
	
#	return options.reduce(
#		func(acc, cur): return get_higher_contrast_to(subject, acc, cur), 
#		{"ratio": 0, "index": 0}
#	)
		
#static func get_higher_contrast_to(subject: Color, option_1: Color, option_2: Color) -> Color:
#	var ratio_1 = get_contrast_ratio(subject, option_1)
#	var ratio_2 = get_contrast_ratio(subject, option_2)
#	return option_1 if ratio_1 >= ratio_2 else option_2

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
