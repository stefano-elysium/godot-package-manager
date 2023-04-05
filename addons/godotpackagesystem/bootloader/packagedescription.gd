@tool
extends Resource
class_name PackageDescription

var filename : String;
var current_version : float = 1.0;
var server_version : float = 1.0;
var description : String;
var export_dirs : PackedStringArray;
var ignore_dirs : PackedStringArray;
var dependencies : PackedStringArray;
var export_dependencies_when_exported : bool;
var accepted_extensions : PackedStringArray = PackedStringArray(["png", "jpg", "webp", "tscn", "gltf", "tres", "gd", "ttf", "json", "spine-json", "atlas", "txt", "material"]);
var root_path_override : String;

func _get_property_list():
	return [
		{ 
			"name": "server_version",
			"type" : TYPE_FLOAT,
			"usage" : PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY,
		},{ 
			"name": "current_version",
			"type" : TYPE_FLOAT,
			"usage" : PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY,
		},{ 
			"name": "filename",
			"type" : TYPE_STRING,
			"usage" : PROPERTY_USAGE_DEFAULT,
		},{
			"name":"description",
			"type":TYPE_STRING,
			"usage" : PROPERTY_USAGE_DEFAULT,
		},{ 
			"name": "export_dirs",
			"type" : TYPE_ARRAY,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ARRAY_TYPE,
			"hint_string" : str(TYPE_STRING)+"/"+str(PROPERTY_HINT_DIR)+":"+"String"
		},{ 
			"name": "ignore_dirs",
			"type" : TYPE_ARRAY,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ARRAY_TYPE,
			"hint_string" : str(TYPE_STRING)+"/"+str(PROPERTY_HINT_DIR)+":"+"String"
		},{ 
			"name": "root_path_override",
			"type" : TYPE_STRING,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_DIR
		},{ 
			"name": "dependencies",
			"type" : TYPE_ARRAY,
			"usage" : PROPERTY_USAGE_DEFAULT
		},{ 
			"name": "export_dependencies_when_exported",
			"type" : TYPE_BOOL,
			"usage" : PROPERTY_USAGE_DEFAULT
		},{ 
			"name": "accepted_extensions",
			"type" : TYPE_ARRAY,
			"usage" : PROPERTY_USAGE_DEFAULT
		}
	]

func export(_already_exported = []):
	print("EXPORTING: ", filename)
	_already_exported.append(filename);	
	if(export_dependencies_when_exported):
		print("DEPENDENCIES: ", filename)
		for dep_path in dependencies:
			var dep = load(dep_path);
			if(_already_exported.has(dep.filename)):
				print("WARNING: Trying to export already exported package ", dep.filename)
				print("Are you sure there are no cyclical dependencies?")
				continue;
			else:
				dep.export(_already_exported);
				
	var exporter;
	if(filename == "bootloader"):
		exporter = BootLoaderExporter.new();
	else:
		exporter = PackageExporter.new();
		
	exporter.package_description = self;
	exporter.export();

func import():
	print ("IMPORTING ", filename)
	if(ProjectSettings.get("loaded_packages") == null):
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
