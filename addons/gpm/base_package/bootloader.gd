extends Node

func _ready():
	print("GPM Bootloader");
	ProjectSettings.load_resource_pack("res://packages/bootloaderpackage.pck")
	
	var list_path = ProjectSettings.get("application/run/root_package_list");
	if(!list_path):
		push_error("ERROR: ROOT PACKAGE LIST NOT SET");
		print("Please set it in your Project Settings - Run - Root Package List")
		return;
	
	load(list_path).import();
	
	var target_scene_path = ProjectSettings.get("application/run/_original_main_scene");
	var scene = load(target_scene_path);
	get_tree().root.call_deferred("add_child", scene.instance());
	#queue_free();
