extends Node

var packages_available : Dictionary;
var packages_loaded : Dictionary;

signal package_importing_done;
signal main_scene_loaded;

func _ready():
	prints("Is editor:", OS.has_feature("editor"));
	if(OS.has_feature("editor") && !(get_tree().current_scene is GPMBootloader)):
		print("Switching to bootloader scene...")
		get_tree().change_scene_to_file("res://addons/godotpackagesystem/bootloader/bootloader_scene.tscn");
