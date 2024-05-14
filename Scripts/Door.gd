extends Node

## Door Component: It handles starting level transitions

enum DataRequestKeys{
	IS_OPENED,
	
}

const CLOSE_ANIMATION = "Closing"
const IDLE_ANIMATION = "Idle"
const OPENING_ANIMATION = "Opening"

const MAIN_MENU_LEVEL = preload("res://Scenes/Levels/MainMenu_level.tscn")

@export_subgroup("Door teleport")
@export_file("*.tscn", "*.scn") var scene_to_load_OnClosed
@export_file("*.tscn", "*.scn") var scene_to_load_OnOpen = MAIN_MENU_LEVEL.get("resource_path")

@export var is_opened:bool = false

@onready var animation:AnimatedSprite2D = $"."
@onready var level_transfer_data_handler:LevelTransferDataHandler = $LevelTransferDataHandler
@onready var interactable:Interactable = %Interactable
@onready var spawn_position:Marker2D = %Marker2D

func _ready() -> void:
	interactable.On_Interacted.connect(on_interacted.bind())
	print(scene_to_load_OnOpen)
	
	if level_transfer_data_handler && level_transfer_data_handler.data_link:
		# If keys were just set, there are no values to load
		if !level_transfer_data_handler.set_data_requests_keys(DataRequestKeys.values())	:
			_load_transfer_data()
			pass
		
		EventBus.on_level_opened.connect(_set_transfer_data.bind())
		
	

func _load_transfer_data() -> void:
	is_opened = level_transfer_data_handler.request_data(DataRequestKeys.IS_OPENED)
	if is_opened:
		animation.play(OPENING_ANIMATION)
		EventBus.on_door_spawn_location_set.emit(spawn_position.global_position)
	else:
		animation.play(CLOSE_ANIMATION)
	

func _set_transfer_data() -> void:
	level_transfer_data_handler.set_data(DataRequestKeys.IS_OPENED, is_opened)
	

func on_interacted() -> void:
	if !is_opened:
		animation.play(OPENING_ANIMATION)
		is_opened = true
	
	_load_level()
	

func _load_level() -> void:
	if is_opened:
		if scene_to_load_OnOpen:
			LevelHandler.load_level(self, load(scene_to_load_OnOpen))
		else:
			LevelHandler.load_level(self, MAIN_MENU_LEVEL)
	else:
		if scene_to_load_OnClosed:
			LevelHandler.load_level(self, load(scene_to_load_OnClosed))
		else:
			LevelHandler.load_level(self, MAIN_MENU_LEVEL)
