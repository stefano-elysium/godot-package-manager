@tool
extends Control
var host = "localhost";
var port = 3000;
var available_package_names : Array = [];
var server_pacakge_version : Array = [];
var http_client : HTTPClient = HTTPClient.new();
var http_headers = ["key:bc6e3a0af8a9481c2f57e80435becbf922f15fbeedc756dafce7c7ecb33296a2"];

var selected_package_name = null;

func _ready():
	http_client.blocking_mode_enabled = true;
	$Bottom/Server/ItemList.item_selected.connect(_on_package_selected);
	$Bottom/Local/LocalItemList.item_selected.connect(_on_local_package_selected);
	$Bottom/ControlRight/Upload.pressed.connect(self.upload);
	$Bottom/ControlRight/Download.pressed.connect(self.download);

func _on_package_selected(i):
	var res = await http_get("/package_info", {"name":available_package_names[i]})
	if(res == null): return; #Push error, eventually
	var output = JSON.parse_string(res.get_string_from_ascii());
	if(output == null): return;
	print(output);
	selected_package_name = available_package_names[i];
	var version = -1;
	if("version" in output[0]):
		version = output[0].version;
	print(PackageServer.get_package_version(selected_package_name));
	$Bottom/ControlRight/Version.text = "version: " + str(version);
	$Bottom/Local/LocalItemList.deselect_all();

func _on_local_package_selected(i):
	$Bottom/Server/ItemList.deselect_all();

func download():
	print("Dowload")
	if(selected_package_name == "" or selected_package_name == null): return;
	var package = await http_get("/download_package", {"name":selected_package_name});
	save_to_file(package);
	var unziped = read_zip_file("res://file.zip");

func save_to_file(buffer):
	var file = FileAccess.open("res://file.zip", FileAccess. WRITE);
	file.store_buffer(buffer);
	file.flush();

func read_zip_file(path):
	var reader := ZIPReader.new()
	var err := reader.open(path)
	if err != OK:
		print("Zipp cannot be opened! " , path)
		return null;
	var res := reader.get_files();
	var packages_path = "res://packages_source/" + selected_package_name + "/";
	var dir = DirAccess.open(packages_path);
	if (!dir): 
		print("No folder found");
		var new_dir = DirAccess.open("res://packages_source/");
		new_dir.make_dir(selected_package_name)
	for file in res:
		var _file = FileAccess.open(packages_path + file, FileAccess.WRITE_READ);
		_file.store_buffer(reader.read_file(file));
	reader.close()
	print("Extracted ");
	PackageServer.plugin.get_editor_interface().get_resource_filesystem().scan();
	return res

func upload():
	print("Uploading...");
	var content = [];
	var dir = DirAccess.open("res://packages_source/" + selected_package_name + "/");
	if(dir):
		dir.list_dir_begin();
		var file_name = dir.get_next();
#		content.append(file_name);
#		while file_name != "":
#			content.append(file_name);

	var body = {
		"name":selected_package_name,
		"version":PackageServer.get_package_version(selected_package_name),
		"description": "no for the moment",
		"author":"Godot",
		"data": Marshalls.raw_to_base64(FileAccess.get_file_as_bytes("res://file.zip"))
	}
	var s = await http_post("/upload_package", JSON.stringify(body));
	print("Uploaded")

func get_packages():
	#Server
	$Bottom/Server/ItemList.clear();
	var res = await http_get("/packages", {})
	if(res == null): return; #Push error, eventually
	var output = JSON.parse_string(res.get_string_from_ascii());
	if(output == null): return;
	available_package_names.clear();
	for path in output:
		available_package_names.append(path.name);
	for package_path in available_package_names:
		$Bottom/Server/ItemList.add_item(package_path)
	#Local
	$Bottom/Local/LocalItemList.clear();
	var dir = DirAccess.open("res://packages_source/");
	if(dir):
		dir.list_dir_begin();
		var packages = dir.get_next();
		var local_packages = dir.get_directories();
		for pack in local_packages:
			$Bottom/Local/LocalItemList.add_item(pack);
		print("Local " , local_packages);

func http_get(path, urlparams):
	return await http_request(path, HTTPClient.METHOD_GET, urlparams);
	
func http_post(path, body):
	return await http_request(path, HTTPClient.METHOD_POST, {}, ["Content-Type:application/json"], body);
	
func http_request(path, type, urlparams = {}, headers = [], body = ""):
	http_client.connect_to_host(host, port)
	while http_client.get_status() == HTTPClient.STATUS_CONNECTING or http_client.get_status() == HTTPClient.STATUS_RESOLVING:
		http_client.poll()
		await get_tree().process_frame

	headers.append_array(http_headers);
	http_client.request(type, path+"?"+http_client.query_string_from_dict(urlparams), headers, body);
	while http_client.get_status() == HTTPClient.STATUS_REQUESTING:
		http_client.poll()
		await get_tree().process_frame

	if(!http_client.has_response()):
		return null;

	var rb = PackedByteArray()
	while http_client.get_status() == HTTPClient.STATUS_BODY:
		http_client.poll()
		rb += http_client.read_response_body_chunk()
		await get_tree().process_frame
		
	return rb;

