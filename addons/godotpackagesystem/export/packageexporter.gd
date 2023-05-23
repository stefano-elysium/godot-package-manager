extends Resource
class_name PackageExporter

var package_description : PackageDescription;
var packer : PCKPacker;
var _paths : Dictionary = {};

func export():
	# prints("Exporting", package_description.filename, "...");

	for path in package_description.export_dirs:
		process_dir_contents(path, path);
		
	var pckpath = "res://packages/";
	DirAccess.make_dir_absolute(pckpath);
	
	packer = PCKPacker.new();
	packer.pck_start(pckpath+package_description.filename+".pck")
	for file in _paths.keys():
		pack_file(file);
	packer.flush(false);
	
func process_dir_contents(path, rootdir):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if(!package_description.ignore_dirs.has(path+"/"+file_name)):
					process_dir_contents(path+"/"+file_name, rootdir);
			else:
				process_file(path+"/"+file_name, rootdir);

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func process_file(path : String, rootdir : String):
	#print("Found file: " + path);
	var extension = path.get_extension();
	if(!package_description.accepted_extensions.has(extension)): return;
	# var folder = path.get_base_dir();
	var import_path = path + ".import";
	if(FileAccess.file_exists(import_path)):
		var import_data = get_file_contents(import_path);
		var imported_file_path = extract_str(import_data, "path=\"", "\"");
		if(package_description.root_path_override):
			var overridepath = path.replace(rootdir, package_description.root_path_override);
			var override_importpath = overridepath+".import"; 			
			#Find if there is something we need to override
			if(FileAccess.file_exists(overridepath) && FileAccess.file_exists(override_importpath)):
				var override_import_data = get_file_contents(override_importpath);
				var override_imported_file_path = extract_str(override_import_data, "path=\"", "\"");
				_paths[override_importpath] = override_importpath;
				_paths[imported_file_path] = override_imported_file_path;
			else:
				_paths[overridepath] = path
				_paths[imported_file_path] = imported_file_path
		else:
			_paths[import_path] = import_path;
			_paths[imported_file_path] = imported_file_path
	else:
		if(package_description.root_path_override):
			var overridepath = path.replace(rootdir, package_description.root_path_override);
			_paths[path] = overridepath
		else:
			_paths[path] = path
		
	#if(_paths[path])
	#_paths[path]=path;

func pack_file(path):
	packer.add_file(_paths[path], path);
	
func extract_str(content, l, r):
	var li = content.find(l) + l.length();
	var ri = content.find(r, li);
	return content.substr(li, ri-li);

func get_file_contents(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return content;
