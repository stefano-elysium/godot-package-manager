@tool
extends EditorPlugin

var editor_inspector_plugin;
var editor_export_plugin;
var editor_menu;

func _enter_tree():
	add_autoload_singleton("PackageServer", "res://addons/godotpackagesystem/bootloader/packageserver.gd")
	editor_inspector_plugin = preload("res://addons/godotpackagesystem/ui/packages_inspector_plugin.gd").new();
	add_inspector_plugin(editor_inspector_plugin)
	editor_export_plugin = preload("res://addons/godotpackagesystem/export/editorexport_plugin.gd").new();
	add_export_plugin(editor_export_plugin)
	editor_menu = load("res://addons/godotpackagesystem/ui/packages_menu.tscn").instantiate();
	_make_visible(false)
	get_editor_interface().get_editor_main_screen().add_child(editor_menu)
	
	print("GPM enabled")

func _exit_tree():
	remove_autoload_singleton("PackageServer")
	remove_inspector_plugin(editor_inspector_plugin)
	editor_inspector_plugin = null;
	remove_export_plugin(editor_export_plugin)
	editor_export_plugin = null;
	if editor_menu: editor_menu.queue_free();
	editor_menu = null;
	print("GPM disabled")
	
func _make_visible(visible):
	if editor_menu: editor_menu.visible = visible

func _has_main_screen():
	return true

func _get_plugin_name():
	return "Packages"

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")

#func _build():
#	ProjectSettings.set("application/run/original_main_scene", ProjectSettings.get("application/run/main_scene"));
#	ProjectSettings.set("application/run/main_scene", "res://addons/godotpackagesystem/bootloader/bootloader_scene.tscn");
#	get_tree().process_frame.connect(_post_build, CONNECT_ONE_SHOT);
#	return true;
#
#func _post_build():
#	ProjectSettings.set("application/run/main_scene", ProjectSettings.get("application/run/original_main_scene"));
