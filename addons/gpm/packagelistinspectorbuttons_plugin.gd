extends EditorInspectorPlugin

var button = preload("res://addons/gpm/packagelistinspectorbutton.gd")
	
func can_handle(object):
	return object is PackageList || object is PackageDescription;

func parse_begin(object):
	add_custom_control(button.new(object))


