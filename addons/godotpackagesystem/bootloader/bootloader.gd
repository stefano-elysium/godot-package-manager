extends Node
class_name GPMBootloader

# const BASE_LOCATION = "res://";
# const PACKAGES_LOCATION = "res://packages_source/"; 
# const PACKAGE_FILE =  "elysiumpackage.json";

const PACKAGES = {
	"base": "res://",
	"source": "res://packages_source/", # TODO renamed it to packages_src
	"built": "res://packages/",
	"file": "elysiumpackage.json"
}

var LOADED_PACKAGES = [];

func _ready():
	print("GPM BOOTLOADER");
	# var list_path = ProjectSettings.get("application/run/main_package_list");
	# print('----- ', list_path); # ----- res://main_package_list.tres -> packagelist.gd
	# var list = load(list_path);
	# list.import(true);
  #
	# PackageServer.emit_signal("package_importing_done");
	# queue_free();

	var package = _parseJSON(PACKAGES.base + PACKAGES.file);
	if package == null: return;

	# print("load this dependencies", package.dependencies.keys());
	for dependency in package.dependencies.keys():
		_import_dependency(dependency);

	for instance_path in package.autoInstantiate: 
		print(PACKAGES.base + instance_path);
		var scene = load(PACKAGES.base + instance_path).instantiate();
		get_tree().root.add_child.call_deferred(scene);

	# res://packages_source/testpck/assets/testautoinstance.tscn
	queue_free();

# TODO is this async?? 
func _import_dependency(name: String):
	var package = _parseJSON(PACKAGES.source + name + "/" + PACKAGES.file);
	var dependencies = package.dependencies.keys() if package != null else [];
	# if package == null || ("name" in package && package.name in LOADED_PACKAGES): return;

	for dependency in dependencies:
		_import_dependency(dependency);

	var pck_path = PACKAGES.built + name + ".pck";
	var was_loaded = ProjectSettings.load_resource_pack(pck_path, true);

	if was_loaded: LOADED_PACKAGES.append(name);
	
	# for instance_path in package.autoInstantiate: 
	# 	var scene = load(PACKAGES.base + instance_path).instantiate();
	# 	get_tree().root.add_child.call_deferred(scene);

	# ProjectSettings.get("loaded_packages").append(filename);
	# PackageServer.packages_loaded[filename] = self;

	# if(ProjectSettings.get("loaded_packages") == null):
	# 	ProjectSettings.set("loaded_packages", []);

	# for dep_package_path in dependencies:
	# 	var dep = load(dep_package_path);
	# 	if(ProjectSettings.get("loaded_packages").has(dep.filename)):
	# 		pass
	# 	else:
	# 		dep.import();
	# 		
	# var pck_path = "res://packages/"+filename+".pck";
	# ProjectSettings.load_resource_pack(pck_path, true)
	# ProjectSettings.get("loaded_packages").append(filename);
	# PackageServer.packages_loaded[filename] = self;
  #
	# for item in auto_preload:
	# 	PackageServer.preloaded_files.append(load(item));
	#
	# if(len(auto_instance) > 0):
	# 	if(is_boot):
	# 		PackageServer.package_importing_done.connect(on_package_importing_done, CONNECT_ONE_SHOT)
	# 	else:
	# 		on_package_importing_done();
	# 		
	# print ("IMPORTED ", filename)


	# print ("IMPORTING ", filename)
	# if(ProjectSettings.get("loaded_packages") == null):
	# 	ProjectSettings.set("loaded_packages", []);
	#
	# for dep_package_path in dependencies:
	# 	var dep = load(dep_package_path);
	# 	if(ProjectSettings.get("loaded_packages").has(dep.filename)):
	# 		pass
	# 	else:
	# 		dep.import();
	# 		
	# var pck_path = "res://packages/"+filename+".pck";
	# ProjectSettings.load_resource_pack(pck_path, true)
	# ProjectSettings.get("loaded_packages").append(filename);
	# PackageServer.packages_loaded[filename] = self;
  #
	# for item in auto_preload:
	# 	PackageServer.preloaded_files.append(load(item));
	#
	# if(len(auto_instance) > 0):
	# 	if(is_boot):
	# 		PackageServer.package_importing_done.connect(on_package_importing_done, CONNECT_ONE_SHOT)
	# 	else:
	# 		on_package_importing_done();
	# 		
	# print ("IMPORTED ", filename)

	pass;

func _parseJSON(path, fallback = null):
	var file = FileAccess.open(path, FileAccess.READ);

	if file == null: 
		# print("ERROR parsing json ", path);
		return fallback;

	var content = file.get_as_text();

	return JSON.parse_string(content);
