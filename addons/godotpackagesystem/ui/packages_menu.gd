@tool
extends Control
var available_package_names : Array = [];

func _ready():
	$Bottom/ControlLeft/ItemList.item_activated.connect(_on_package_selected);
	
func _on_package_selected(i):
	print(i);

func get_packages():
	$Bottom/ControlLeft/ItemList.clear();
	
	var output = []
	var exit_code = OS.execute("git", ["branch", "-r"], output)
	available_package_names.clear();
	for path in output[0].split("\n", false):
		available_package_names.append(path.dedent().replace("origin/", ""))

	for package_path in available_package_names:
		$Bottom/ControlLeft/ItemList.add_item(package_path)


