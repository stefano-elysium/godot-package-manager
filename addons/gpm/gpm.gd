tool
extends EditorPlugin

var package_list_inspector_buttons_plugin
var editor_export_plugin

func _enter_tree():
	package_list_inspector_buttons_plugin = preload("res://addons/gpm/packagelistinspectorbuttons_plugin.gd").new()
	add_inspector_plugin(package_list_inspector_buttons_plugin)
	add_custom_type(
		"PackageDescription", 
		"Resource", 
		preload("res://addons/gpm/base_package/packagedescription.gd"), 
		preload("res://addons/gpm/base_package/assets/icondesc.png"))
	add_custom_type(
		"PackageList", 
		"Resource", 
		preload("res://addons/gpm/base_package/packagelist.gd"), 
		preload("res://addons/gpm/base_package/assets/iconlist.png"))
		
	editor_export_plugin = preload("res://addons/gpm/export/editorpackageexporterplugin.gd").new();
	add_export_plugin(editor_export_plugin)
	
	print("GPM Initialized");
	
	if(!ProjectSettings.get("application/run/root_package_list")):
		print("WARNING: NO ROOT PACKAGE LIST SET");
		print("Please set it in your Project Settings - Run - Root Package List")
		ProjectSettings.set("application/run/root_package_list", "")
		var property_info = {
			"name": "application/run/root_package_list",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
		}
		ProjectSettings.add_property_info(property_info)


func _exit_tree():
	remove_inspector_plugin(package_list_inspector_buttons_plugin)
	remove_custom_type("PackageDescription")
	remove_custom_type("PackageList")
	remove_export_plugin(editor_export_plugin)
