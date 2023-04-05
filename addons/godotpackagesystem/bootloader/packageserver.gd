@tool
extends Node

var packages_available : Dictionary;
var packages_loaded : Dictionary;
var plugin;

signal package_importing_done;
signal main_scene_loaded;

var _all_packages : Array;

func _ready():
	prints("Is editor:", OS.has_feature("editor"));
	_load_packages();
	return;
	if(OS.has_feature("editor") && !(get_tree().current_scene is GPMBootloader) && !Engine.is_editor_hint()):
		print("Switching to bootloader scene...")
		get_tree().change_scene_to_file("res://addons/godotpackagesystem/bootloader/bootloader_scene.tscn");

func _load_packages():
	var path = "res://packages_source/";
	var dir = DirAccess.open(path)
	if dir:
		print("dirs " , dir.get_directories());
		for sub in dir.get_directories():
			var sub_path = path+sub;
			var sub_folder = DirAccess.open(sub_path);
			sub_folder.list_dir_begin();
			var file_name = sub_folder.get_next()
			while file_name != "":
				if(file_name.get_extension() == "tres"):
					var file = sub_path+"/"+file_name;
					var package = load(file);
					_all_packages.append(package);
					print("version " , package.current_version);
				file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func get_package_version(package_name):
	var version = -1;
	for package in _all_packages:
		if(package.filename == package_name):
			version = package.current_version;
	return version;

func get_description(package_name):
	for package in _all_packages:
		if(package.filename == package_name):
			return package.description;
	return "";
