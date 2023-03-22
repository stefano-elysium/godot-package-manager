@tool
extends Control
var host = "localhost";
var port = 3000;
var available_package_names : Array = [];
var http_client : HTTPClient = HTTPClient.new();
var http_headers = ["key:bc6e3a0af8a9481c2f57e80435becbf922f15fbeedc756dafce7c7ecb33296a2"];

func _ready():
	http_client.blocking_mode_enabled = true;
	$Bottom/ControlLeft/ItemList.item_activated.connect(_on_package_selected);
	
func _on_package_selected(i):
	var res = await http_get("/package_info", {"name":available_package_names[i]})
	if(res == null): return; #Push error, eventually
	var output = JSON.parse_string(res.get_string_from_ascii());
	if(output == null): return;
	print(output);
	var package = await http_get("/download_package", {"name":available_package_names[i]});
	var file = FileAccess.open("res://file.7z", FileAccess. WRITE);
	file.store_buffer(package);
	file.flush();
	print("Downloaded")
	#Extract
	print("Extracting...");
	var unziped = read_zip_file("res://file.7z");
	var _file = FileAccess.open("res://" + available_package_names[i], FileAccess.WRITE_READ);
	_file.store_buffer(unziped);
	file.flush();
	print("Extracted ", available_package_names[i])

func read_zip_file(path):
	var reader := ZIPReader.new()
	var err := reader.open(path)
	if err != OK:
		print("Zip not opened ", err)
		return PackedByteArray()
	var res := reader.read_file(path)
	reader.close()
	return res


func get_packages():
	$Bottom/ControlLeft/ItemList.clear();
	var res = await http_get("/packages", {})
	if(res == null): return; #Push error, eventually
	var output = JSON.parse_string(res.get_string_from_ascii());
	if(output == null): return;
	available_package_names.clear();
	
	for path in output:
		available_package_names.append(path.name)
		
	for package_path in available_package_names:
		$Bottom/ControlLeft/ItemList.add_item(package_path)

func http_get(path, data):
	http_client.connect_to_host(host, port)
	while http_client.get_status() == HTTPClient.STATUS_CONNECTING or http_client.get_status() == HTTPClient.STATUS_RESOLVING:
		http_client.poll()
		await get_tree().process_frame
	
	http_client.request(HTTPClient.METHOD_GET, path+"?"+http_client.query_string_from_dict(data), http_headers, "");
	while http_client.get_status() == HTTPClient.STATUS_REQUESTING:
		http_client.poll()
		await get_tree().process_frame

	if(!http_client.has_response()):
		return null;
		
	var rb = PackedByteArray()
	while http_client.get_status() == HTTPClient.STATUS_BODY:
		http_client.poll()
		rb += http_client.read_response_body_chunk()
		print("CHUNK")
		await get_tree().process_frame
		
	return rb;
	

