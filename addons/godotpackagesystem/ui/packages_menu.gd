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
	#$Bottom/ControlLeft/ItemList.item_activated.connect(_on_package_selected);
	$Bottom/ControlLeft/ItemList.item_selected.connect(_on_package_selected);
	$Bottom/ControlRight/Upload.pressed.connect(self.upload);

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
	$Bottom/ControlRight/Version.text = "version: " + str(version);

func download():
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
	var res := reader.get_files()
	for file in res:
		var _file = FileAccess.open("res://Downloaded/" + file, FileAccess.WRITE_READ);
		_file.store_buffer(reader.read_file(file));
	reader.close()
	print("Extracted ");
	return res

	
func upload():

	print("Uploading...")
	var body = {
		"name":"file.zip",
		"data": Marshalls.raw_to_base64(FileAccess.get_file_as_bytes("res://file.zip"))
	}
	var s = await http_post("/upload_package", JSON.stringify(body));
	print("Uploaded")

func get_packages():
	$Bottom/ControlLeft/ItemList.clear();
	var res = await http_get("/packages", {})
	if(res == null): return; #Push error, eventually
	var output = JSON.parse_string(res.get_string_from_ascii());
	if(output == null): return;
	available_package_names.clear();
	
	for path in output:
		available_package_names.append(path.name);

	for package_path in available_package_names:
		$Bottom/ControlLeft/ItemList.add_item(package_path)

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

