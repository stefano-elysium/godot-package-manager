@tool
extends EditorInspectorPlugin
class_name PackagesInspectorPlugin

func _can_handle(object):
	return object is PackageList || object is PackageDescription;

func _parse_begin(object):
	add_custom_control(PackagesExportButton.new(object))
