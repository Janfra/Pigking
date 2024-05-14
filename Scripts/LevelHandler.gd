class_name LevelHandler
extends RefCounted

static var s_data_to_transfer:Dictionary
static var s_transition:AnimationPlayer
static var s_is_transitioning:bool

const scene_transition = preload("res://Scenes/LevelTransition.tscn")
const start_transitio_animation = "StartTransition"
const end_transition_animation = "EndTransition"

static func load_level(requestingNode:Node, level:PackedScene) -> void:
	if s_is_transitioning:
		printerr("Already transitioning")
		return
	
	if !requestingNode || !requestingNode.is_inside_tree():
		printerr("Node requesting to load level is invalid")
		return
	
	if !level || !level.can_instantiate():
		printerr("%s is attempting to load invalid level" %requestingNode.name)
		return
	
	var nodeTree:SceneTree = requestingNode.get_tree()
	if !s_transition:
		if !_create_transition(nodeTree):
			return
	
	# Notify group of new scene
	EventBus.on_level_opened.emit()
	
	# Start transitioning and wait for animation to end
	s_is_transitioning = true
	s_transition.play(start_transitio_animation)
	await s_transition.animation_finished
	
	# Start changing scene
	nodeTree.change_scene_to_packed(level)
	
	# Double checking that we didnt lose the transition when changing scene
	if !s_transition:
		printerr("Transition no longer valid")
		s_is_transitioning = false
		return
	s_transition.play_backwards(start_transitio_animation)
	s_is_transitioning = false
	print("Transitioned to new level")
	

static func _create_transition(rootProvider:SceneTree) -> bool:
	# INFO: Create and find the animation player
	var transitionInstance = scene_transition.instantiate()
	if transitionInstance is AnimationPlayer:
		s_transition = transitionInstance as AnimationPlayer
	else:
		var instanceChildren = transitionInstance.get_children()
		for children in instanceChildren:
			if children is AnimationPlayer:
				s_transition = children as AnimationPlayer
	
	if !s_transition:
		printerr("No transition available")
		return false
		
	
	# INFO: Parent it to keep it active
	rootProvider.root.add_child(s_transition.owner)
	if s_transition.owner:
		s_transition.owner.owner = rootProvider.root
	else:
		s_transition.owner = rootProvider.root
	return true
	
