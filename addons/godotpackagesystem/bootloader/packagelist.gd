@tool
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
		
func import(is_bool=false):
	for package_path in packages:

		# res://packages_source/testpck/testpck.tres -> packagedescription.gd
		# res://packages_source/testpck_override/testpck_override.tres -> packagedescription.gd
		print("package path: ", package_path);
		load(package_path).import(is_bool);
