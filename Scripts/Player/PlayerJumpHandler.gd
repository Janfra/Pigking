extends Node
class_name PlayerJumpHandler

const MINIMUM_GRAVITY_MULTIPLIER = 0.01

#region Editable Variables
@export_group("Jump")
@export_subgroup("Dependencies")
@export var player:CharacterBody2D

@export_subgroup("Velocity")
@export var jumpVelocity:float = -300.0
@export var jumpCutMultiplier:float = 0.2

@export_subgroup("Falling Speed")
@export var fallingGravityMultiplier:float = 1
@export var ascendingGravityMultiplier:float = 1
@export var downInputGravityMultiplier:float = 1.2
@export var maxFallSpeed:float = 300

@export_subgroup("Grace Timers")
@export var coyoteTime:float = 0.2
@export var jumpQueuedTime:float = 0.2
#endregion

#region Logic booleans
# INFO: Has coyote time already being applied
var hasCoyoteTime:bool = false

# INFO: Has the player already jumped
var hasJumped:bool = false

# INFO: Is the player able to perform a jump
var canJump:bool = false

# INFO: Can jump cut be performed
var canJumpCut:bool = false

var isFalling:bool = false

var isDownInput:bool = false
#endregion

# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyoteTime_Timer:Timer 
var jumpInput_Timer:Timer

#region Warning Check
func _get_configuration_warnings():
	if !player:
		return ["No player set for jumping"]
	
	return []
#endregion

func try_jump() -> void:
	if hasJumped:
		return
	
	if !_is_jump_valid():
		jumpInput_Timer.start(jumpQueuedTime)
		return
	
	_queue_jump()

func try_jump_cut() -> void:
	if !hasJumped || !canJumpCut:
		return
	
	_cut_jump()
	

func increase_fall_speed(isInput:bool) -> void:
	isDownInput = isInput
	

#region Init
func _init() -> void:
	_setup_coyote_time_timer()
	_setup_jump_input_timer()
	update_configuration_warnings()
	

func _ready() -> void:
	assert(player, "Add player reference to player jump handler")
	

func _setup_coyote_time_timer() -> void:
	coyoteTime_Timer = Timer.new()
	add_child(coyoteTime_Timer)
	coyoteTime_Timer.owner = owner
	coyoteTime_Timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	coyoteTime_Timer.one_shot = true
	coyoteTime_Timer.timeout.connect(self._invalidate_coyote_time.bind())
	

func _setup_jump_input_timer() -> void:
	jumpInput_Timer = Timer.new()
	add_child(jumpInput_Timer)
	jumpInput_Timer.owner = owner
	jumpInput_Timer.process_callback = Timer.TIMER_PROCESS_IDLE
	jumpInput_Timer.one_shot = true
	
#endregion

#region General Handling
func process_jump(delta:float) -> void:
	if !player:
		printerr("No player assigned to", owner.name)
		return
	
	if _is_jump_queued():
		_jump()
	elif !player.is_on_floor():
		_handle_off_ground(delta)
	else:
		_handle_landing()
	 
	if(!jumpInput_Timer.is_stopped() && _is_jump_valid()):
		_queue_jump()
	

func _handle_off_ground(delta: float) -> void:
	isFalling = player.velocity.y > 0
	_apply_gravity(delta)
	
	if isFalling:
		canJumpCut = false
		_clamp_fall_speed()
	
	if _should_coyote_time_start():
		_start_coyote_time()
	

func _handle_landing() -> void:
	hasJumped = false
	hasCoyoteTime = false
	canJumpCut = true
	canJump = true
	_stop_coyote_time()
	

#endregion

#region Falling Speed / Gravity

func _clamp_fall_speed() -> void:
	player.velocity.y = min(maxFallSpeed, player.velocity.y)

func _apply_gravity(delta:float) -> void:
	if isDownInput:
		player.velocity.y += (gravity * downInputGravityMultiplier) * delta
	else:
		if isFalling:
			player.velocity.y += (gravity * fallingGravityMultiplier) * delta
		else:
			player.velocity.y += (gravity * ascendingGravityMultiplier) * delta
	

#endregion

#region Jump logic
func _jump() -> void:
	player.velocity.y = 0
	player.velocity.y += jumpVelocity
	canJump = false
	hasJumped = true

func _cut_jump() -> void:
	player.velocity.y -= player.velocity.y * (1 - jumpCutMultiplier)
	canJumpCut = false
	

func _is_jump_queued() -> bool:
	return hasJumped && canJump

func _queue_jump() -> void:
	hasJumped = true
	canJump = true
	jumpInput_Timer.stop()

func _is_jump_valid() -> bool:
	return !coyoteTime_Timer.is_stopped() || player.is_on_floor()
#endregion

#region Coyote Time
func _should_coyote_time_start() -> bool:
	return !hasJumped && !hasCoyoteTime && coyoteTime_Timer.is_stopped()

func _start_coyote_time() -> void:
	coyoteTime_Timer.start(coyoteTime)
	

func _stop_coyote_time() -> void:
	if coyoteTime_Timer.is_stopped():
		return
	
	coyoteTime_Timer.stop()
	hasCoyoteTime = true
	

func _invalidate_coyote_time() -> void:
	hasCoyoteTime = true
	
#endregion
