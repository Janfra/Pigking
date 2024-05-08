extends Node

@export_subgroup("Door teleport")
@export var scene_To_Load_OnClosed:PackedScene
@export var isOpened = false
const MAIN_MENU_LEVEL = preload("res://Scenes/Levels/MainMenu_level.tscn")

@onready var interactable = $Interactable

func _ready() -> void:
	interactable.On_Interacted.connect(on_interacted.bind())
	

func on_interacted() -> void:
	_load_level()

func _load_level() -> void:
	if isOpened:
		LevelHandler.load_level(self, MAIN_MENU_LEVEL)
	else:
		LevelHandler.load_level(self, scene_To_Load_OnClosed)
