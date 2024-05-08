extends RefCounted
class_name LevelHandler

static var s_dataToTransfer:Dictionary
static var s_transition:AnimationPlayer
static var s_isTransitioning:bool
const NEW_LEVEL_TRANSFER_DATA_GROUP = "LevelDataTransfer"
const sceneTransition = preload("res://Scenes/LevelTransition.tscn")
const startTransitionAnimation = "StartTransition"
const endTransitionAnimation = "EndTransition"

static func load_level(requestingNode:Node, level:PackedScene) -> void:
	if s_isTransitioning:
		printerr("Already transitioning")
		return
	
	if !requestingNode || !requestingNode.is_inside_tree():
		printerr("Node requesting to load level is invalid")
		return
	
	if !level || !level.can_instantiate():
		printerr("%s is attempting to load invalid level" %requestingNode.name)
		return
	
	var nodeTree = requestingNode.get_tree()
	s_isTransitioning = true
	
	# Add transition
	if !s_transition:
		var rootChildren = sceneTransition.instantiate().get_children()
		for children in rootChildren:
			if children is AnimationPlayer:
				s_transition = children as AnimationPlayer
		
		if !s_transition:
			printerr("No transition available")
			s_isTransitioning = false
			return
		
		nodeTree.root.add_child(s_transition.owner)
		s_transition.owner.owner = nodeTree.root
	
	s_transition.play(startTransitionAnimation)
	await s_transition.animation_finished
	
	# Notify group of new scene
	nodeTree.notify_group(NEW_LEVEL_TRANSFER_DATA_GROUP, 0)
	nodeTree.change_scene_to_packed(level)
	
	if !s_transition:
		printerr("Transition no longer valid")
		s_isTransitioning = false
		return
	s_transition.play_backwards(startTransitionAnimation)
	s_isTransitioning = false
	print("Transitioned to new level")
	
