@tool
class_name LevelDataLink
extends Resource

@export var linked_to:String = "Undefined Linker - Set name"
@export var are_keys_set:bool = false
var data:Dictionary

# INFO: For now just to bring awareness of selected linker
func register_linker(handler:LevelTransferDataHandler) -> void:
	if !handler:
		printerr("Trying to add data transfer link with null object")
		return 
	
	print("Linked %s to %s" %[handler.owner.name, linked_to])
	

func set_dictionary_keys(keys:Array, printAddedKeys:bool = false, override:bool = false) -> bool:
	if are_keys_set && !override:
		return false
	
	print("Keys for %s have been set" %linked_to)
	are_keys_set = true
	if !data.is_empty():
		data.clear()
	
	var addedKeys:String = "Added keys:"
	for key in keys:
		addedKeys += " " + str(key)
		data[key] = null
	
	if printAddedKeys:
		print(addedKeys)
	return true

func set_data(key:Variant, newData:Variant) -> void:
	if data.has(key):
		data[key] = newData
	

func request_data(key:Variant) -> Variant:
	if data.has(key):
		return data[key]
	else:
		return null
	
