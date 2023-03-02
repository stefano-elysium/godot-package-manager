extends EditorExportPlugin
class_name EditorPackageExporter
var target_path;
func _export_begin(features: PoolStringArray, is_debug: bool, path: String, flags: int):
	target_path = path;
	
	if(ProjectSettings.get("application/run/main_scene") != "res://addons/gpm/base_package/bootloader.tscn"):
		ProjectSettings.set("application/run/_original_main_scene", ProjectSettings.get("application/run/main_scene"))
		ProjectSettings.set("application/run/main_scene", "res://addons/gpm/base_package/bootloader.tscn")
		
func _export_file(path: String, type: String, features: PoolStringArray):
	#skip();
	pass
	
func _export_end():
	var list_path = ProjectSettings.get("application/run/root_package_list");
	if(!list_path):
		push_error("ERROR: ROOT PACKAGE LIST NOT SET");
		print("Please set it in your Project Settings - Run - Root Package List")
		return;

	var filename = target_path.get_basename().get_file();

	var dir = Directory.new()
	var base_dir = target_path.get_base_dir();
	dir.remove(base_dir+"/packages")
	dir.make_dir(base_dir+"/packages")
	dir.remove(base_dir+"/"+filename+".pck")
	dir.remove(base_dir+"/"+filename+".zip")
	
	var list = load(list_path);
	PackageList.export(list);
	
	var bootloader_package = load("res://addons/gpm/_bootloaderpackage.tres");
	if(!list.export_bootloader): PackageDescription.export(bootloader_package);
	
	copy_dir("res://packages", base_dir+"/packages")

	var bootloader_path = base_dir+"/"+filename+".pck";
	dir.copy("res://packages/"+bootloader_package.filename+".pck", bootloader_path)

	
func copy_dir(from, to):
	var dir = Directory.new()
	if dir.open(from) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while (file_name != ""):
			var filediff = to+"/"+file_name;

			dir.copy(from+"/"+file_name, filediff)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
