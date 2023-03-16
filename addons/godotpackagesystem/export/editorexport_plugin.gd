@tool
extends EditorExportPlugin

var target_path;

func _get_name():
	return "GPMExportPlugin"
	
func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int):
	target_path = path;
	
func _export_file(path: String, type: String, features: PackedStringArray):
	skip();
	
func _export_end():
	var list_path = ProjectSettings.get("application/run/main_package_list");
	if(list_path == null || list_path == "" || load(list_path) == null):
		push_error("ERROR: MAIN PACKAGE LIST NOT SET");
		print("Please set it in your Project Settings - Run - Main Package List")
		return;

	var filename = target_path.get_basename().get_file();

	var dir = DirAccess.open("res://");
	var base_dir = target_path.get_base_dir();
	dir.remove(base_dir+"/packages")
	dir.make_dir(base_dir+"/packages")
	dir.remove(base_dir+"/"+filename+".pck")
	dir.remove(base_dir+"/"+filename+".zip")
	
	var list = load(list_path)
	list.export();
	
	var bootloader_package = load("res://addons/godotpackagesystem/export/bootloaderpck.tres");
	if(!list.export_bootloader): bootloader_package.export();
	
	copy_dir("res://packages", base_dir+"/packages")

	var bootloader_path = base_dir+"/"+filename+".pck";
	dir.copy("res://packages/"+bootloader_package.filename+".pck", bootloader_path)
	
func copy_dir(from, to):
	var dir = DirAccess.open(from);
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		var filediff = to+"/"+file_name;
		dir.copy(from+"/"+file_name, filediff)
		file_name = dir.get_next()




