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
	if isOpened && MAIN_MENU_LEVEL.can_instantiate():
		get_tree().change_scene_to_packed(MAIN_MENU_LEVEL)
	elif MAIN_MENU_LEVEL.can_instantiate():
		assert(scene_To_Load_OnClosed, "Scene to load not set on " + self.name)
		get_tree().change_scene_to_packed(scene_To_Load_OnClosed)
	else:
		printerr("Main menu not found")
