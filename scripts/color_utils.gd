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
