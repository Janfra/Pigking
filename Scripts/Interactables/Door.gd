extends Interactable

@export var Scene_To_Load_OnClosed:PackedScene
@export var Scene_To_Load_OnOpened:PackedScene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func interact():
	print("Door interacted")

func _load_next_level():
	get_tree().change_scene_to_packed(Scene_To_Load_OnClosed)
