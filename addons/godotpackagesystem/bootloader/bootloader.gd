extends Node
class_name GPMBootloader

func _ready():
	print("GPM BOOTLOADER");
	var list_path = ProjectSettings.get("application/run/main_package_list");
	var list = load(list_path).import();
	PackageServer.emit_signal("package_importing_done");
	get_tree().change_scene_to_file(ProjectSettings.get("application/run/original_main_scene"));
	PackageServer.emit_signal("main_scene_loaded");
