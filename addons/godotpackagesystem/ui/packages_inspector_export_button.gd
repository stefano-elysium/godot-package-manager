@tool
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
