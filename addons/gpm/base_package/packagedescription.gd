extends Resource
class_name PackageDescription

export (String) var filename;
export (Array, String, DIR) var paths;
export (Array, String, DIR) var ignore_paths;
export (String, DIR) var root_path_override;
export (Array, String) var accepted_extensions = ["png", "jpg", "webp", "tscn", "gltf", "tres", "gd", "ttf", "json", "spine-json", "atlas", "txt", "material"];
export (bool) var export_dependencies_when_exported;
export (Array, String, FILE) var dependencies;

static func export(res, _already_exported = []):
	if(res is String): 
		res = load(res);
	
	_already_exported.append(res.filename);	
	if(res.export_dependencies_when_exported):
		print("DEPENDENCIES: ", res.filename)
		for dep_path in res.dependencies:
			var dep = load(dep_path);
			if(_already_exported.has(dep.filename)):
				print("WARNING: Trying to export already exported package ", dep.filename)
				print("Are you sure there are no cyclical dependencies?")
				continue;
			else:
				export(dep, _already_exported);
				
	var exporter = load("res://addons/gpm/scenes/package_exporter.tscn").instance();
	exporter.package_description = res;
	exporter.export_package();
	exporter.free();
	
func import():
	print("IMPORTING ", filename)
	
	if(!ProjectSettings.get("loaded_packages")):
		ProjectSettings.set("loaded_packages", []);
	
	for dep_package_path in dependencies:
		var dep = load(dep_package_path);
		if(ProjectSettings.get("loaded_packages").has(dep.filename)):
			pass
		else:
			dep.import();
	
	var pck_path = "res://packages/"+filename+".pck";
	ProjectSettings.load_resource_pack(pck_path, true)
	ProjectSettings.get("loaded_packages").append(filename);
	print ("IMPORTED ", filename)
	
	#print(ProjectSettings.get("loaded_packages"))
	
