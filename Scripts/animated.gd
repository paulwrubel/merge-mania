class_name Animated
extends Node2D

var parent_property_name: String
var parent_property_value: Variant
var duration_seconds: float
var ease: Tween.EaseType
var trans: Tween.TransitionType
var on_finished: Callable

var is_animating := false

# Called when the node enters the scene tree for the first time.
func _ready():
	is_animating = true
	var block = get_parent()
	var tween = create_tween()
	tween.tween_property(block, parent_property_name, parent_property_value, duration_seconds) \
		.set_ease(ease) \
		.set_trans(trans)
	var callback = func():
		on_finished.call(block)
		is_animating = false
	tween.tween_callback(callback)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
