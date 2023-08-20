class_name AnimationSubject
extends RefCounted

var subject: Object
var property_name: String
var property_value: Variant


func _init(subject_: Object, prop_name_: String, prop_value_: Variant):
	self.subject = subject_
	self.property_name = prop_name_
	self.property_value = prop_value_
