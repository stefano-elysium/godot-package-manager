extends HBoxContainer

var button; 
var obj;

func _init(obj):
	self.obj = obj;
	
	alignment = BoxContainer.ALIGN_CENTER
	size_flags_horizontal = SIZE_EXPAND_FILL

	button = Button.new();
	add_child(button)
	button.size_flags_horizontal = SIZE_EXPAND_FILL
		
	if(obj is PackageList):
		button.text = "EXPORT ALL";
	elif(obj is PackageDescription):
		button.text = "EXPORT";
		
	button.connect("pressed", self, "on_button_pressed")

func on_button_pressed():
	if(obj is PackageList):
		PackageList.export(obj);
	elif(obj is PackageDescription):
		PackageDescription.export(obj);
