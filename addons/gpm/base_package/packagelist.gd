extends Resource
class_name PackageList

export (Array, String, FILE) var packages;
export (bool) var export_bootloader;

static func export(res):
	prints("EXPORTING LIST", res.resource_path, OS.get_time())
	if(res.export_bootloader): 
		PackageDescription.export("res://addons/gpm/_bootloaderpackage.tres");
		
	for package_path in res.packages:
		PackageDescription.export(package_path);
		
	prints("done list", res.resource_path, OS.get_time())
	
func import():
	for package_path in packages:
		load(package_path).import();

