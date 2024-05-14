@tool
class_name LevelDataLink
extends Resource
## Stores data for syncing objects in different scenes

#region Exported Variables
## Describes intended link - Doesnt affect logic
@export var linked_to:String = "Undefined Linker - Set name"

## Are keys lock
@export var are_keys_set:bool = false
#endregion

## Data stored for syncing objects
var data:Dictionary

# INFO: For now just to bring awareness of selected linker
func register_linker(handler:LevelTransferDataHandler) -> void:
	if !handler:
		printerr("Trying to add data transfer link with null object")
		return 
	
	print("Linked %s to %s" %[handler.owner.name, linked_to])
	

## Defines the keys that will be used to store and retrieve data
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

## Defines the data stored at the given key
func set_data(key:Variant, newData:Variant) -> void:
	if data.has(key):
		data[key] = newData
	

## Retrieves the data stored at the given key
func request_data(key:Variant) -> Variant:
	if data.has(key):
		return data[key]
	else:
		return null
	
