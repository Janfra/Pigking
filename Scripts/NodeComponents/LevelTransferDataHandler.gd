@tool
class_name LevelTransferDataHandler
extends Node

@export var disabled:bool
@export var receive_data:bool
@export var data_link:LevelDataLink:
	get: 
		return data_link
	set(value):
		data_link = value
		if Engine.is_editor_hint():
			if value:
				data_link.register_linker(self)
		
		update_configuration_warnings()
		

func _get_configuration_warnings():
	if disabled:
		return []
	
	if !data_link:
		return ["No object data holder selected to link"]
	
	return []
	

func set_data(key:Variant, newData:Variant) -> void:
	if !data_link:
		return
	
	data_link.set_data(key, newData)
	

func request_data(key:Variant) -> Variant:
	if !data_link:
		return null
	
	return data_link.request_data(key)
	

func request_all_data() -> Dictionary:
	if !data_link:
		return {}
	
	return data_link.data
	

func set_data_requests_keys(keys:Array, printAddedKeys:bool = false, override:bool = false) -> bool:
	if !data_link:
		return false
	
	if data_link.are_keys_set && !override:
		return false
	
	return data_link.set_dictionary_keys(keys, printAddedKeys, override)
	
