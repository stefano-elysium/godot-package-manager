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
		
func import():
	for package_path in packages:
		load(package_path).import();
