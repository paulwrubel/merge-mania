class_name AnimationSubject
extends RefCounted

var subject: Object
var property_name: String
var property_value: Variant

func _init(_subject: Object, _prop_name: String, _prop_value: Variant):
	self.subject = _subject
	self.property_name = _prop_name
	self.property_value = _prop_value
