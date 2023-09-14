extends MarginContainer

signal close_button_pressed()

var global_left_label: RichTextLabel = null
var global_right_label: RichTextLabel = null

var save_left_label: RichTextLabel = null
var save_right_label: RichTextLabel = null

var found_labels: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_find_labels()


func set_statistics(global_stats: GlobalStatistics, save_stats: SaveStatistics):
	if not found_labels:
		_find_labels()

	_add_global_stat_row("total merges", global_stats.merge_count)
	var max_level = 0
	for level in global_stats.max_level.values():
		max_level = max(max_level, level)
	_add_global_stat_row("max level reached", max_level)

	_add_save_stat_row("total merges", save_stats.merge_count)
	_add_save_stat_row("max blocks in single merge", save_stats.max_merge)
	_add_save_stat_row("max steps in merge chain", save_stats.max_chain)
	_add_save_stat_row("total blocks snapped from level up", save_stats.blocks_snapped)


func _add_global_stat_row(key: String, val: Variant):
	global_left_label.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	global_left_label.append_text("{0}".format([key]))
	global_left_label.pop()

	global_right_label.push_paragraph(HORIZONTAL_ALIGNMENT_RIGHT)
	global_right_label.append_text("{0}".format([val]))
	global_right_label.pop()


func _add_save_stat_row(key: String, val: Variant):
	save_left_label.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	save_left_label.append_text("{0}".format([key]))
	save_left_label.pop()

	save_right_label.push_paragraph(HORIZONTAL_ALIGNMENT_RIGHT)
	save_right_label.append_text("{0}".format([val]))
	save_right_label.pop()


func _find_labels():
	global_left_label = $PanelContainer/MarginContainer/VBoxContainer/GlobalPanelContainer/HBoxContainer/StatsLabelLeft
	global_right_label = $PanelContainer/MarginContainer/VBoxContainer/GlobalPanelContainer/HBoxContainer/StatsLabelRight
	
	save_left_label = $PanelContainer/MarginContainer/VBoxContainer/SavePanelContainer/HBoxContainer/StatsLabelLeft
	save_right_label = $PanelContainer/MarginContainer/VBoxContainer/SavePanelContainer/HBoxContainer/StatsLabelRight

	found_labels = true


func _on_close_button_pressed():
	close_button_pressed.emit()
