class_name TweenSettings
extends RefCounted

var duration_seconds: float
var easing: Tween.EaseType
var transition: Tween.TransitionType

func _init(_duration_seconds: float, _easing: Tween.EaseType, _transition: Tween.TransitionType):
	self.duration_seconds = _duration_seconds
	self.easing = _easing
	self.transition = _transition
