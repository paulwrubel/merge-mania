class_name TweenSettings
extends RefCounted

var duration_seconds: float
var easing: Tween.EaseType
var transition: Tween.TransitionType


func _init(duration_seconds_: float, easing_: Tween.EaseType, transition_: Tween.TransitionType):
	self.duration_seconds = duration_seconds_
	self.easing = easing_
	self.transition = transition_
