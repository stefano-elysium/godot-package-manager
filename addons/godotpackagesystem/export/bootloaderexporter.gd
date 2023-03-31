extends PackageExporter
class_name BootLoaderExporter

func export():
	package_description = load("res://addons/godotpackagesystem/export/bootloaderpck.tres");
	prints("Exporting BOOTLOADER ", package_description.filename, "...");

	for path in package_description.export_dirs:
		process_dir_contents(path, path);
		
	var pckpath = "res://packages/";
	DirAccess.make_dir_absolute(pckpath);
	
	packer = PCKPacker.new();
	packer.pck_start(pckpath+package_description.filename+".pck")
	for file in _paths.keys():
		pack_file(file);

	packer.add_file("res://project.godot", "res://project.godot")
	generate_cfg();
	packer.add_file("res://override.cfg", "res://override.cfg")
	packer.add_file("res://icon.svg", "res://icon.svg")
	packer.add_file("res://.godot/global_script_class_cache.cfg", "res://.godot/global_script_class_cache.cfg")
	packer.add_file("res://.godot/uid_cache.bin", "res://.godot/uid_cache.bin")
	for data in ProjectSettings.get_global_class_list():
		packer.add_file(data.path, data.path)
	
	var list_path = ProjectSettings.get("application/run/main_package_list");
	if(list_path == null):
		push_error("ERROR: MAIN PACKAGE LIST NOT SET");
		print("Please set it in your Project Settings - Run - Main Package List")
		return;
		
	packer.add_file(list_path, list_path);
		
	var already_packed = [];
	var list = load(list_path);
	for package_path in list.packages:
		pack_package_description(load(package_path), packer, already_packed);
				
	packer.flush(false);

func generate_cfg():
	var file = FileAccess.open("res://override.cfg", FileAccess.WRITE)
	var content = "application/run/main_scene=\"res://addons/godotpackagesystem/bootloader/bootloader_scene.tscn\"";
	if(ProjectSettings.get("application/run/main_scene") == "res://addons/godotpackagesystem/bootloader/bootloader_scene.tscn"):
		content += "\napplication/run/original_main_scene=\""+ProjectSettings.get("application/run/original_main_scene")+"\""
	else:
		content += "\napplication/run/original_main_scene=\""+ProjectSettings.get("application/run/main_scene")+"\""
	file.store_string(content);
	file.close()

func pack_package_description(package_description, packer, already_packed):
	if(already_packed.has(package_description.filename)): return;
	packer.add_file(package_description.resource_path, package_description.resource_path);
	already_packed.append(package_description.filename);
	for dep in package_description.dependencies:
		pack_package_description(load(dep), packer, already_packed);
