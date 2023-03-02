tool
extends Node
class_name PackageExporter

export(int) var split_size = -1;
export(Resource) var package_description;
signal export_completed;

var _manifest : Dictionary = {};

var is_bootloader;

func export_package():
	prints("Exporting", package_description.filename, "...");
	
	is_bootloader = package_description is BootloaderPackageDescription;
	if(is_bootloader): print("BOOTLOADER")
	
	var paths = get_paths();

	var packer = PCKPacker.new()
	var pckpath = "res://packages/";
	
	load_manifest();
	
	Directory.new().make_dir_recursive(pckpath);
	
	var curname = package_description.filename;
	var split_id = -1;
	if(split_size > -1): split_id = 0;
	var current_size = 0;
	_manifest[package_description.filename] = {};
	_manifest[package_description.filename]["packs"] = [];
	packer.pck_start(pckpath+curname+".pck");
	
	if(is_bootloader):
		if(ProjectSettings.get("application/run/main_scene") != "res://addons/gpm/base_package/bootloader.tscn"):
			ProjectSettings.set("application/run/_original_main_scene", ProjectSettings.get("application/run/main_scene"))
			ProjectSettings.set("application/run/main_scene", "res://addons/gpm/base_package/bootloader.tscn")
		
		ProjectSettings.save_custom("res://project.binary")
		#packer.add_file("res://project.godot", "res://project.godot")
		packer.add_file("res://project.binary", "res://project.binary")
		_manifest[package_description.filename]["is_bootloader"] = true;
		var list_path = ProjectSettings.get("application/run/root_package_list");
		if(!list_path):
			push_error("ERROR: ROOT PACKAGE LIST NOT SET");
			print("Please set it in your Project Settings - Run - Root Package List")
			return;
		packer.add_file(list_path, list_path)

		var already_packed = [];
		var list = load(list_path);
		for package_path in list.packages:
			pack_package_description(load(package_path), packer, already_packed);
		
		var default_env = ProjectSettings.get("rendering/environment/default_environment")
		packer.add_file(default_env, default_env)
		var icon = ProjectSettings.get("application/config/icon")
		packer.add_file(icon, icon)
		
		var projectdata = get_file_contents("res://project.godot");
		if("[autoload]" in projectdata):
			var autoload_data = extract_str(projectdata, "[autoload]", "[editor_plugins]").rsplit("\n", false);
			for path in autoload_data:
				path = extract_str(path, "\"", "\"")
				if(path[0]=="*"):
					path = path.lstrip("*");
					packer.add_file(path, path)
		
	for path in paths.keys(): 
		packer.add_file(paths[path], path)
		var file = File.new()
		file.open(path, File.READ)
		current_size += file.get_len();
		file.close()
		
		if(split_size > -1 && current_size > split_size):
			split_id += 1;
			packer.flush()
			
			var abspath = (pckpath+curname+".pck").replace("res:/", "");
			_manifest[package_description.filename]["packs"].append([abspath, current_size]);
			curname = package_description.filename + String(split_id);
			prints("Generated", curname, String.humanize_size(current_size));
			current_size = 0;
			split_id += 1;
			packer.pck_start(pckpath+curname+".pck");
				
	packer.flush()
	
	if(is_bootloader):
		#ProjectSettings.set_setting("application/run/main_scene", oldmainscene)
		Directory.new().remove("res://project.binary");
		
	var abspath = (pckpath+curname+".pck").replace("res:/", "");
	_manifest[package_description.filename]["packs"].append([abspath, current_size]);
	
	#if(is_translation): _manifest[package_description.filename]["is_translation"] = is_translation;
	#if(is_translation): _manifest[package_description.filename]["is_optional"] = is_optional;
	
	save_manifest();
	prints("Generated", curname, String.humanize_size(current_size));
	emit_signal("export_completed");

func get_dir_contents(rootPath: String) -> Array:
	var files = []
	var dir = Directory.new()

	if dir.open(rootPath) == OK:
		dir.list_dir_begin(true, false)
		_add_dir_contents(dir, files)
	else:
		push_error("An error occurred when trying to access the path.")

	return files

func _add_dir_contents(dir: Directory, files : Array):
	var file_name = dir.get_next()
		
	while (file_name != ""):
		var path = dir.get_current_dir() + "/" + file_name

		if dir.current_is_dir():
			#print("Found directory: %s" % path)
			var subDir = Directory.new()
			subDir.open(path)
			subDir.list_dir_begin(true, false)
			_add_dir_contents(subDir, files)
		else:
			#print("Found file: %s" % path)
			files.append(path)

		file_name = dir.get_next()
		while(file_name.begins_with(".")): 
			file_name = dir.get_next()

	dir.list_dir_end()

func save_manifest():
	var file = File.new()
	file.open("res://manifest.json", File.WRITE);
	file.store_line(to_json(_manifest))
	file.close()

func load_manifest():
	var file = File.new()
	if not file.file_exists("res://manifest.json"):
		save_manifest()
		return
	file.open("res://manifest.json", File.READ)
	var data = parse_json(file.get_as_text())
	_manifest = data;

func get_paths():
	var paths = {};
		
	for folder in package_description.paths:
		var files = get_dir_contents(folder);
		for path in files:	
			if(!package_description.accepted_extensions.has(path.get_extension())): continue;
			var import = path+".import";
			
			if(files.has(import)):
				var content = get_file_contents(import);
				var importpath = extract_str(content,'dest_files=[ "', '" ]');
				if(package_description.root_path_override):
					var originalpath = path.replace(folder, package_description.root_path_override);
					var originalimportpath = originalpath+".import";
					var originalimportcontent = get_file_contents(originalimportpath);
					var overridepath = extract_str(originalimportcontent,'dest_files=[ "', '" ]');
					paths[originalimportpath] = originalimportpath;
					paths[importpath] = overridepath;
				else:
					paths[import] = import;
					paths[importpath] = importpath
			else:
				#paths[import] = import;
				if(package_description.root_path_override):
					var overridepath = path.replace(folder, package_description.root_path_override);
					paths[path] = overridepath;
				else:					
					paths[path] = path;	
	return paths;

func extract_str(content, l, r):
	var li = content.find(l) + l.length();
	var ri = content.find(r, li);
	return content.substr(li, ri-li);

func get_file_contents(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content;
	
func pack_package_description(package_description, packer, already_packed):
	if(already_packed.has(package_description.filename)): return;
	packer.add_file(package_description.resource_path, package_description.resource_path);
	already_packed.append(package_description.filename);
	for dep in package_description.dependencies:
		pack_package_description(load(dep), packer, already_packed);
