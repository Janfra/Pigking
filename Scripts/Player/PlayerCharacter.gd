class_name PlayerCharacter
extends CharacterBody2D
## Manages player related logic

#region Consts & Enums
# Request Constants
enum DataRequestKeys{
	HEALTH,
	
}

# Constants
const SPEED = 170.0
const SPEED_SLOWDOWN_MULTIPLIER = 0.3

# Input Constants
const JUMP_INPUT = "jump"
const MOVE_NEGATIVE_X_INPUT = "move_left"
const MOVE_POSITIVE_X_INPUT = "move_right"
const MOVE_NEGATIVE_Y_INPUT = "move_down"
const INTERACT_INPUT = "interact"

#endregion

#region Exported Variables
# Set References
@export var animation_handler:PlayerAnimationHandler
#endregion

#region Internal Variables
var interaction_node:Interactable 
var input:Vector2 
var last_valid_input:Vector2 
#endregion

#region On Ready
@onready var player_jump_handler:PlayerJumpHandler = $PlayerJumpHandler
@onready var level_transfer_data_handler:LevelTransferDataHandler = %LevelTransferDataHandler
@onready var health_component:HealthComponent = %HealthComponent

#endregion

func _init() -> void:
	# Need to find way of verifying that input names are always correct
	assert(InputMap.has_action(JUMP_INPUT), "Jump action name has been changed, update to match")
	assert(InputMap.has_action(MOVE_NEGATIVE_X_INPUT), "Move negative action name has been changed, update to match")
	assert(InputMap.has_action(MOVE_POSITIVE_X_INPUT), "Move positive action name has been changed, update to match")
	assert(InputMap.has_action(INTERACT_INPUT), "Interact action name has been changed, update to match")
	
	EventBus.on_door_spawn_location_set.connect(_enter_level.bind())
	

func _ready() -> void:
	if level_transfer_data_handler:
		level_transfer_data_handler.set_data_requests_keys(DataRequestKeys.values())
		_load_transfer_data()
		EventBus.on_level_opened.connect(_set_transfer_data.bind())
		
	
	
	assert(animation_handler, "Set animation handler")
	assert(player_jump_handler, "Set jump handler")
	

## Retrieves the data that was stored when changing scenes
func _load_transfer_data():
	var health = level_transfer_data_handler.request_data(DataRequestKeys.HEALTH)
	if health:
		health_component.health = health
	

## Stores data to be retrieved when changing scenes
func _set_transfer_data() -> void:
	if health_component:
		level_transfer_data_handler.set_data(DataRequestKeys.HEALTH, health_component.health)
	

## Setups player when entering a new level
func _enter_level(spawnLocation:Vector2):
	global_position = spawnLocation
	

## Handles incoming input data
func _unhandled_key_input(event) -> void:
	if Input.is_action_just_pressed(JUMP_INPUT, true):
		player_jump_handler.try_jump()
	elif Input.is_action_just_released(JUMP_INPUT):
		player_jump_handler.try_jump_cut()
	
	if Input.is_action_just_pressed(MOVE_NEGATIVE_Y_INPUT):
		player_jump_handler.increase_fall_speed(true)
	elif Input.is_action_just_released(MOVE_NEGATIVE_Y_INPUT):
		player_jump_handler.increase_fall_speed(false)
	
	if InputMap.action_has_event(MOVE_NEGATIVE_X_INPUT, event) || InputMap.action_has_event(MOVE_POSITIVE_X_INPUT, event):
		input.x = Input.get_axis(MOVE_NEGATIVE_X_INPUT, MOVE_POSITIVE_X_INPUT)
	
	if interaction_node && Input.is_action_just_pressed("interact"):
		interaction_node.interact()
	

func _physics_process(delta) -> void:
	player_jump_handler.process_jump(delta)
	_handle_sideways_movement()
	
	animation_handler.handle_movement_animations(velocity, input, last_valid_input)
	move_and_slide()
	

## Temporary handler for movement
func _handle_sideways_movement() -> void:
	if input.x != 0:
		velocity.x = input.x * SPEED
		last_valid_input.x = input.x
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * SPEED_SLOWDOWN_MULTIPLIER)
	

## @experimental Enables interaction with an object
func start_interaction_process(newInteractionNode: Interactable) -> void:
	interaction_node = newInteractionNode
	

## @experimental Disables interaction with an object
func stop_interaction_process() -> void:
	interaction_node = null
	
