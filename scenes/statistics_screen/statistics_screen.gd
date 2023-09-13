extends MarginContainer

signal close_button_pressed()

var left_label: RichTextLabel = null
var right_label: RichTextLabel = null


# Called when the node enters the scene tree for the first time.
func _ready():
	_find_labels()


func set_statistics(save_stats: SaveStatistics):
	if left_label == null or right_label == null:
		_find_labels()

	_add_stat_row("total merges", save_stats.merge_count)
	_add_stat_row("max blocks in single merge", save_stats.max_merge)
	_add_stat_row("max steps in merge chain", save_stats.max_chain)
	_add_stat_row("total blocks snapped from level up", save_stats.blocks_snapped)


func _add_stat_row(key: String, val: Variant):
	left_label.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	left_label.append_text("{0}".format([key]))
	left_label.pop()

	right_label.push_paragraph(HORIZONTAL_ALIGNMENT_RIGHT)
	right_label.append_text("{0}".format([val]))
	right_label.pop()


func _find_labels():
	left_label = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/HBoxContainer/StatsLabelLeft
	right_label = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/HBoxContainer/StatsLabelRight


func _on_close_button_pressed():
	close_button_pressed.emit()
