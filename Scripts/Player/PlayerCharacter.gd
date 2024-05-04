extends CharacterBody2D
class_name PlayerCharacter

# Constants
const SPEED = 170.0
const SPEED_SLOWDOWN_MULTIPLIER = 0.3

# Input Constants
const JUMP_INPUT = "jump"
const MOVE_NEGATIVE_X_INPUT = "move_left"
const MOVE_POSITIVE_X_INPUT = "move_right"
const INTERACT_INPUT = "interact"

# References
@export var animation_Handler:PlayerAnimationHandler
@onready var player_Jump_Handler:PlayerJumpHandler = $PlayerJumpHandler

var InteractionNode:Interactable 
var input:Vector2 
var last_Valid_Input:Vector2 

func _init():
	# Need to find way of verifying that input names are always correct
	assert(InputMap.has_action(JUMP_INPUT), "Jump action name has been changed, update to match")
	assert(InputMap.has_action(MOVE_NEGATIVE_X_INPUT), "Move negative action name has been changed, update to match")
	assert(InputMap.has_action(MOVE_POSITIVE_X_INPUT), "Move positive action name has been changed, update to match")
	assert(InputMap.has_action(INTERACT_INPUT), "Interact action name has been changed, update to match")

func _unhandled_key_input(event):
	var isHandled := false
	if Input.is_action_just_pressed(JUMP_INPUT):
		isHandled = true
		player_Jump_Handler.try_jump()
	
	if InputMap.action_has_event(MOVE_NEGATIVE_X_INPUT, event) || InputMap.action_has_event(MOVE_POSITIVE_X_INPUT, event):
		isHandled = true
		input.x = Input.get_axis(MOVE_NEGATIVE_X_INPUT, MOVE_POSITIVE_X_INPUT)
	
	if InteractionNode && Input.is_action_just_pressed("interact"):
		InteractionNode.interact()
	
	if isHandled:
		get_viewport().set_input_as_handled()
	

func _physics_process(delta):
	player_Jump_Handler.process_jump(delta)
	_handle_sideways_movement()
	
	animation_Handler.handle_movement_animations(velocity, input, last_Valid_Input)
	move_and_slide()
	

func _handle_sideways_movement():
	if input.x != 0:
		velocity.x = input.x * SPEED
		last_Valid_Input.x = input.x
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * SPEED_SLOWDOWN_MULTIPLIER)
	

func start_interaction_process(NewInteractionNode: Interactable):
	InteractionNode = NewInteractionNode

func stop_interaction_process():
	InteractionNode = null
