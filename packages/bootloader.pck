GDPC                 �                                                                         8   res://addons/godotpackagesystem/bootloader/bootloader.gd              +?�B�_�߁܂�e�    <   res://addons/godotpackagesystem/bootloader/packageserver.gd        �      &� yg�0�����    @   res://addons/godotpackagesystem/bootloader/bootloader_scene.tscn             ���sn�Ǻ�y��~��    @   res://addons/godotpackagesystem/bootloader/packagedescription.gd 
      �      �Cpś\�A�w��!�    <   res://addons/godotpackagesystem/bootloader/packagelist.gd   �      �      8nB���W�^�g�6<       res://project.godot �      }      R�%��<���=���       res://override.cfg  @       �       �3ꔐ�vҞ��sC���       res://icon.svg   !      N      ]��s�9^w/�����    ,   res://.godot/global_script_class_cache.cfg  `1      �      �"���)�HjkL���r       res://.godot/uid_cache.bin   6      r      ��O���YxTx�3    <   res://addons/godotpackagesystem/export/bootloaderexporter.gd�9      �	      ��� ]14[���l��    8   res://addons/godotpackagesystem/bootloader/bootloader.gd`C            +?�B�_�߁܂�e�    @   res://addons/godotpackagesystem/bootloader/packagedescription.gd�D      �      �Cpś\�A�w��!�    <   res://addons/godotpackagesystem/export/packageexporter.gd    T            	8�K3�q�A�V��    <   res://addons/godotpackagesystem/bootloader/packagelist.gd   @_      �      8nB���W�^�g�6<    H   res://addons/godotpackagesystem/ui/packages_inspector_export_button.gd  @b             ޮ�/%�v����`t�    @   res://addons/godotpackagesystem/ui/packages_inspector_plugin.gd `d      �       M%��~@3�1{�H�{       res://main_package_list.tres`e      �      "u	�C�������    ,   res://packages_source/testpck/testpck.tres   g      ?      [BA{AJ����7��    <   res://packages_source/testpck_override/testpck_override.tres`j      �      ����΁�f������    �����1:}�E�s^Y05�extends Node
class_name GPMBootloader

func _ready():
	print("GPM BOOTLOADER");
	var list_path = ProjectSettings.get("application/run/main_package_list");
	var list = load(list_path);
	list.import();
						
	PackageServer.emit_signal("package_importing_done");
	queue_free();
J�&�]ULm@tool
extends Node

var packages_loaded : Dictionary;
var preloaded_files : Array;
var plugin;

signal package_importing_done;

var _all_packages : Array;

func _ready():
	prints("Is editor:", OS.has_feature("editor"));
	_load_packages();
	
	if(OS.has_feature("editor") && !(get_tree().current_scene is GPMBootloader) && !Engine.is_editor_hint()):
		print("Switching to bootloader scene...")
		get_tree().change_scene_to_file("res://addons/godotpackagesystem/bootloader/bootloader_scene.tscn");
	
		
func _load_packages():
	var path = "res://packages_source/";
	var dir = DirAccess.open(path)
	if dir:
		#print("dirs " , dir.get_directories());
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
		print("An error occurred when trying to access the packages path.")

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
0�[gd_scene load_steps=2 format=3 uid="uid://br5kg1ne5blx2"]

[ext_resource type="Script" path="res://addons/godotpackagesystem/bootloader/bootloader.gd" id="1_33sqk"]

[node name="bootloader_scene" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1_33sqk")

[node name="ColorRect" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0, 0, 0, 1)

[node name="Label" type="Label" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
text = "-GPM-
   Loading..."
horizontal_alignment = 1
vertical_alignment = 1
0�a�/�C�� �@tool
extends Resource
class_name PackageDescription

var filename : String;
var current_version : float = 1.0;
var server_version : float = 1.0;
var description : String;
var export_dirs : PackedStringArray;
var ignore_dirs : PackedStringArray;
var dependencies : PackedStringArray;
var auto_instance : PackedStringArray;
var auto_preload : PackedStringArray;
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
		},{ 
			"name": "auto_instance",
			"type" : TYPE_ARRAY,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ARRAY_TYPE,
			"hint_string" : str(TYPE_STRING)+"/"+str(PROPERTY_HINT_FILE)+":"+"*.tscn"
		},{ 
			"name": "auto_preload",
			"type" : TYPE_ARRAY,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ARRAY_TYPE,
			"hint_string" : str(TYPE_STRING)+"/"+str(PROPERTY_HINT_FILE)+":"+"String"
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
	PackageServer.packages_loaded[filename] = self;
	for item in auto_preload:
		PackageServer.preloaded_files.append(load(item));
		
	if(len(auto_instance) > 0):
		PackageServer.package_importing_done.connect(on_main_scene_loaded, CONNECT_ONE_SHOT)
		
	print ("IMPORTED ", filename)
	
func on_main_scene_loaded():
	for packedscene in auto_instance:
		var scene = load(packedscene).instantiate();
		PackageServer.get_tree().root.add_child.call_deferred(scene);
�S��@tool
extends Resource
class_name PackageList

var export_bootloader : bool;
var packages : PackedStringArray;

func _get_property_list():
	return [
		{
			"name": "packages",
			"type" : TYPE_ARRAY,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ARRAY_TYPE,
			"hint_string" : str(TYPE_STRING)+"/"+str(PROPERTY_HINT_FILE)+":"+""
		}, {
			"name": "export_bootloader",
			"type" : TYPE_BOOL,
			"usage" : PROPERTY_USAGE_DEFAULT
		}
	]

func export():
	var _already_exported = []
	for package_path in packages:
		load(package_path).export(_already_exported);
		
	if(export_bootloader):
		load("res://addons/godotpackagesystem/export/bootloaderpck.tres").export();
		
func import():
	for package_path in packages:
		load(package_path).import();
^��/�=Y; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="packagesystem"
run/main_scene="res://addons/godotpackagesystem/bootloader/bootloader_scene.tscn"
config/features=PackedStringArray("4.0", "GL Compatibility")
config/icon="res://icon.svg"
run/main_package_list="res://main_package_list.tres"
run/original_main_scene="res://packages_source/testpck/assets/test.tscn"

[autoload]

PackageServer="*res://addons/godotpackagesystem/bootloader/packageserver.gd"

[editor_plugins]

enabled=PackedStringArray("res://addons/godotpackagesystem/plugin.cfg")

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
�>�application/run/main_scene="res://addons/godotpackagesystem/bootloader/bootloader_scene.tscn"
application/run/original_main_scene="res://packages_source/testpck/assets/test.tscn"���%�=J��F�1z�<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><g transform="translate(32 32)"><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99z" fill="#363d52"/><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99zm0 4h96c6.64 0 12 5.35 12 11.99v95.98c0 6.64-5.35 11.99-12 11.99h-96c-6.64 0-12-5.35-12-11.99v-95.98c0-6.64 5.36-11.99 12-11.99z" fill-opacity=".4"/></g><g stroke-width="9.92746" transform="matrix(.10073078 0 0 .10073078 12.425923 2.256365)"><path d="m0 0s-.325 1.994-.515 1.976l-36.182-3.491c-2.879-.278-5.115-2.574-5.317-5.459l-.994-14.247-27.992-1.997-1.904 12.912c-.424 2.872-2.932 5.037-5.835 5.037h-38.188c-2.902 0-5.41-2.165-5.834-5.037l-1.905-12.912-27.992 1.997-.994 14.247c-.202 2.886-2.438 5.182-5.317 5.46l-36.2 3.49c-.187.018-.324-1.978-.511-1.978l-.049-7.83 30.658-4.944 1.004-14.374c.203-2.91 2.551-5.263 5.463-5.472l38.551-2.75c.146-.01.29-.016.434-.016 2.897 0 5.401 2.166 5.825 5.038l1.959 13.286h28.005l1.959-13.286c.423-2.871 2.93-5.037 5.831-5.037.142 0 .284.005.423.015l38.556 2.75c2.911.209 5.26 2.562 5.463 5.472l1.003 14.374 30.645 4.966z" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 919.24059 771.67186)"/><path d="m0 0v-47.514-6.035-5.492c.108-.001.216-.005.323-.015l36.196-3.49c1.896-.183 3.382-1.709 3.514-3.609l1.116-15.978 31.574-2.253 2.175 14.747c.282 1.912 1.922 3.329 3.856 3.329h38.188c1.933 0 3.573-1.417 3.855-3.329l2.175-14.747 31.575 2.253 1.115 15.978c.133 1.9 1.618 3.425 3.514 3.609l36.182 3.49c.107.01.214.014.322.015v4.711l.015.005v54.325c5.09692 6.4164715 9.92323 13.494208 13.621 19.449-5.651 9.62-12.575 18.217-19.976 26.182-6.864-3.455-13.531-7.369-19.828-11.534-3.151 3.132-6.7 5.694-10.186 8.372-3.425 2.751-7.285 4.768-10.946 7.118 1.09 8.117 1.629 16.108 1.846 24.448-9.446 4.754-19.519 7.906-29.708 10.17-4.068-6.837-7.788-14.241-11.028-21.479-3.842.642-7.702.88-11.567.926v.006c-.027 0-.052-.006-.075-.006-.024 0-.049.006-.073.006v-.006c-3.872-.046-7.729-.284-11.572-.926-3.238 7.238-6.956 14.642-11.03 21.479-10.184-2.264-20.258-5.416-29.703-10.17.216-8.34.755-16.331 1.848-24.448-3.668-2.35-7.523-4.367-10.949-7.118-3.481-2.678-7.036-5.24-10.188-8.372-6.297 4.165-12.962 8.079-19.828 11.534-7.401-7.965-14.321-16.562-19.974-26.182 4.4426579-6.973692 9.2079702-13.9828876 13.621-19.449z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 104.69892 525.90697)"/><path d="m0 0-1.121-16.063c-.135-1.936-1.675-3.477-3.611-3.616l-38.555-2.751c-.094-.007-.188-.01-.281-.01-1.916 0-3.569 1.406-3.852 3.33l-2.211 14.994h-31.459l-2.211-14.994c-.297-2.018-2.101-3.469-4.133-3.32l-38.555 2.751c-1.936.139-3.476 1.68-3.611 3.616l-1.121 16.063-32.547 3.138c.015-3.498.06-7.33.06-8.093 0-34.374 43.605-50.896 97.781-51.086h.066.067c54.176.19 97.766 16.712 97.766 51.086 0 .777.047 4.593.063 8.093z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 784.07144 817.24284)"/><path d="m0 0c0-12.052-9.765-21.815-21.813-21.815-12.042 0-21.81 9.763-21.81 21.815 0 12.044 9.768 21.802 21.81 21.802 12.048 0 21.813-9.758 21.813-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 389.21484 625.67104)"/><path d="m0 0c0-7.994-6.479-14.473-14.479-14.473-7.996 0-14.479 6.479-14.479 14.473s6.483 14.479 14.479 14.479c8 0 14.479-6.485 14.479-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 367.36686 631.05679)"/><path d="m0 0c-3.878 0-7.021 2.858-7.021 6.381v20.081c0 3.52 3.143 6.381 7.021 6.381s7.028-2.861 7.028-6.381v-20.081c0-3.523-3.15-6.381-7.028-6.381" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 511.99336 724.73954)"/><path d="m0 0c0-12.052 9.765-21.815 21.815-21.815 12.041 0 21.808 9.763 21.808 21.815 0 12.044-9.767 21.802-21.808 21.802-12.05 0-21.815-9.758-21.815-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 634.78706 625.67104)"/><path d="m0 0c0-7.994 6.477-14.473 14.471-14.473 8.002 0 14.479 6.479 14.479 14.473s-6.477 14.479-14.479 14.479c-7.994 0-14.471-6.485-14.471-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 656.64056 631.05679)"/></g></svg>
�4|��e����kp�VZlist=Array[Dictionary]([{
"base": &"PackageExporter",
"class": &"BootLoaderExporter",
"icon": "",
"language": &"GDScript",
"path": "res://addons/godotpackagesystem/export/bootloaderexporter.gd"
}, {
"base": &"Node",
"class": &"GPMBootloader",
"icon": "",
"language": &"GDScript",
"path": "res://addons/godotpackagesystem/bootloader/bootloader.gd"
}, {
"base": &"Resource",
"class": &"PackageDescription",
"icon": "",
"language": &"GDScript",
"path": "res://addons/godotpackagesystem/bootloader/packagedescription.gd"
}, {
"base": &"Resource",
"class": &"PackageExporter",
"icon": "",
"language": &"GDScript",
"path": "res://addons/godotpackagesystem/export/packageexporter.gd"
}, {
"base": &"Resource",
"class": &"PackageList",
"icon": "",
"language": &"GDScript",
"path": "res://addons/godotpackagesystem/bootloader/packagelist.gd"
}, {
"base": &"HBoxContainer",
"class": &"PackagesExportButton",
"icon": "",
"language": &"GDScript",
"path": "res://addons/godotpackagesystem/ui/packages_inspector_export_button.gd"
}, {
"base": &"EditorInspectorPlugin",
"class": &"PackagesInspectorPlugin",
"icon": "",
"language": &"GDScript",
"path": "res://addons/godotpackagesystem/ui/packages_inspector_plugin.gd"
}])
 q�Ҋ�i>.   �R��䠋2@   res://addons/godotpackagesystem/bootloader/bootloader_scene.tscn�B�T�6�/9   res://addons/godotpackagesystem/export/bootloaderpck.treswP�6���;5   res://addons/godotpackagesystem/ui/packages_menu.tscnG�C%�T!;   res://packages_source/testpck/assets/BackgroundFlatNEW.webp��Q]��.   res://packages_source/testpck/assets/icon1.png��_i�JE.   res://packages_source/testpck/assets/test.tscn�2:�D~v*   res://packages_source/testpck/testpck.tres(���PGF7   res://packages_source/testpck_override/assets/icon1.png��9t�	z   res://icon.svgpM6�h�Ws   res://main_package_list.tresn���6'*
   res://test.tscnԦ�%gM8   res://packages_source/AnotherPackage/AnotherPackage.tres����;   res://packages_source/AnotherPackage/BackgroundFlatNEW.webpfZ�u;��8.   res://packages_source/testpck/assets/test.tscnM�`C�>v:   res://packages_source/testpck/assets/testautoinstance.tscn��n�3Dt�Lnextends PackageExporter
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
���Hθ�N�l�B���1�extends Node
class_name GPMBootloader

func _ready():
	print("GPM BOOTLOADER");
	var list_path = ProjectSettings.get("application/run/main_package_list");
	var list = load(list_path);
	list.import();
						
	PackageServer.emit_signal("package_importing_done");
	queue_free();
�sb��RK��@tool
extends Resource
class_name PackageDescription

var filename : String;
var current_version : float = 1.0;
var server_version : float = 1.0;
var description : String;
var export_dirs : PackedStringArray;
var ignore_dirs : PackedStringArray;
var dependencies : PackedStringArray;
var auto_instance : PackedStringArray;
var auto_preload : PackedStringArray;
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
		},{ 
			"name": "auto_instance",
			"type" : TYPE_ARRAY,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ARRAY_TYPE,
			"hint_string" : str(TYPE_STRING)+"/"+str(PROPERTY_HINT_FILE)+":"+"*.tscn"
		},{ 
			"name": "auto_preload",
			"type" : TYPE_ARRAY,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ARRAY_TYPE,
			"hint_string" : str(TYPE_STRING)+"/"+str(PROPERTY_HINT_FILE)+":"+"String"
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
	PackageServer.packages_loaded[filename] = self;
	for item in auto_preload:
		PackageServer.preloaded_files.append(load(item));
		
	if(len(auto_instance) > 0):
		PackageServer.package_importing_done.connect(on_main_scene_loaded, CONNECT_ONE_SHOT)
		
	print ("IMPORTED ", filename)
	
func on_main_scene_loaded():
	for packedscene in auto_instance:
		var scene = load(packedscene).instantiate();
		PackageServer.get_tree().root.add_child.call_deferred(scene);
��'�extends Resource
class_name PackageExporter

var package_description : PackageDescription;
var packer : PCKPacker;
var _paths : Dictionary = {};

func export():
	#prints("Exporting", package_description.filename, "...");

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
	var folder = path.get_base_dir();
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
��g�����C]�!�@tool
extends Resource
class_name PackageList

var export_bootloader : bool;
var packages : PackedStringArray;

func _get_property_list():
	return [
		{
			"name": "packages",
			"type" : TYPE_ARRAY,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ARRAY_TYPE,
			"hint_string" : str(TYPE_STRING)+"/"+str(PROPERTY_HINT_FILE)+":"+""
		}, {
			"name": "export_bootloader",
			"type" : TYPE_BOOL,
			"usage" : PROPERTY_USAGE_DEFAULT
		}
	]

func export():
	var _already_exported = []
	for package_path in packages:
		load(package_path).export(_already_exported);
		
	if(export_bootloader):
		load("res://addons/godotpackagesystem/export/bootloaderpck.tres").export();
		
func import():
	for package_path in packages:
		load(package_path).import();
��"#�j@tool
extends HBoxContainer
class_name PackagesExportButton

var button; 
var obj;

func _init(obj):
	self.obj = obj;
	
	alignment = BoxContainer.ALIGNMENT_CENTER
	size_flags_horizontal = SIZE_EXPAND_FILL

	button = Button.new();
	add_child(button)
	button.size_flags_horizontal = SIZE_EXPAND_FILL
		
	if(obj is PackageList):
		button.text = "EXPORT ALL";
	elif(obj is PackageDescription):
		button.text = "EXPORT";
		
	button.pressed.connect(on_button_pressed.bind(obj))

func on_button_pressed(obj):
	obj.export();
��OP����nA�}�e�;Iz��Z�@tool
extends EditorInspectorPlugin
class_name PackagesInspectorPlugin

func _can_handle(object):
	return object is PackageList || object is PackageDescription;

func _parse_begin(object):
	add_custom_control(PackagesExportButton.new(object))
XӎNYl�- P�[gd_resource type="Resource" script_class="PackageList" load_steps=2 format=3 uid="uid://dqobru7g3hvc7"]

[ext_resource type="Script" path="res://addons/godotpackagesystem/bootloader/packagelist.gd" id="1_d5pcc"]

[resource]
script = ExtResource("1_d5pcc")
packages = PackedStringArray("res://packages_source/testpck/testpck.tres", "res://packages_source/testpck_override/testpck_override.tres")
export_bootloader = true
�o�NY����@_�O�X �v�.qL��$�[gd_resource type="Resource" script_class="PackageDescription" load_steps=2 format=3 uid="uid://hwq07qr47v3v"]

[ext_resource type="Script" path="res://addons/godotpackagesystem/bootloader/packagedescription.gd" id="1_1y7bj"]

[resource]
script = ExtResource("1_1y7bj")
server_version = 1.0
current_version = 1.0
filename = "testpck"
description = ""
export_dirs = PackedStringArray("res://packages_source/testpck")
ignore_dirs = PackedStringArray()
root_path_override = ""
dependencies = PackedStringArray()
export_dependencies_when_exported = false
accepted_extensions = PackedStringArray("png", "jpg", "webp", "tscn", "gltf", "tres", "gd", "ttf", "json", "spine-json", "atlas", "txt", "material")
auto_instance = PackedStringArray("res://packages_source/testpck/assets/testautoinstance.tscn")
auto_preload = PackedStringArray()
B[gd_resource type="Resource" script_class="PackageDescription" load_steps=2 format=3]

[ext_resource type="Script" path="res://addons/godotpackagesystem/bootloader/packagedescription.gd" id="1_8kf1g"]

[resource]
script = ExtResource("1_8kf1g")
server_version = 1.0
current_version = 1.0
filename = "testpck_override"
export_dirs = PackedStringArray("res://packages_source/testpck_override")
ignore_dirs = PackedStringArray()
root_path_override = "res://packages_source/testpck"
dependencies = PackedStringArray()
accepted_extensions = PackedStringArray("png", "jpg", "webp", "tscn", "gltf", "tres", "gd", "ttf", "json", "spine-json", "atlas", "txt", "material")
3����d���