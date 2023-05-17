extends Node
class_name GPMBootloader

func _ready():
	print("GPM BOOTLOADER");
	var list_path = ProjectSettings.get("application/run/main_package_list");
	var list = load(list_path);
	list.import(true);
						
	PackageServer.emit_signal("package_importing_done");
	queue_free();
