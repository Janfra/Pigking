extends Node
class_name PlayerJumpHandler

@export_subgroup("Jump")
@export var player:CharacterBody2D 
@export var coyote_time:float = 0.2
@export var jumpQueued_time:float = 0.2
@export var jump_Velocity:float = -300.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity:float = ProjectSettings.get_setting("physics/2d/default_gravity")	

var coyoteTime_Timer:Timer 
var jumpInput_Timer:Timer

var hasJumped:bool = false
var hasCoyoteTime:bool = false
var canJump:bool = false

func _init():
	_setup_coyote_time_timer()
	_setup_jump_input_timer()
	if gravity == 0:
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	

func _ready():
	assert(player, "Add player reference to player jump handler")
	

func _setup_coyote_time_timer():
	coyoteTime_Timer = Timer.new()
	add_child(coyoteTime_Timer)
	coyoteTime_Timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	coyoteTime_Timer.one_shot = true
	coyoteTime_Timer.timeout.connect(self._invalidate_coyote_time.bind())
	

func _setup_jump_input_timer():
	jumpInput_Timer = Timer.new()
	add_child(jumpInput_Timer)
	jumpInput_Timer.process_callback = Timer.TIMER_PROCESS_IDLE
	jumpInput_Timer.one_shot = true
	

func process_jump(delta:float):
	if !player:
		printerr("No player assigned to", owner.name)
		return
	
	if(!jumpInput_Timer.is_stopped() && _is_jump_valid()):
		_queue_jump()
	
	if hasJumped && canJump:
		_jump()
	elif !player.is_on_floor():
		_handle_falling(delta)
	else:
		hasJumped = false
		hasCoyoteTime = false
		canJump = true
		_stop_coyote_time()
	 

func _jump():
	player.velocity.y = 0
	player.velocity.y += jump_Velocity
	canJump = false
	hasJumped = true

func _start_coyote_time():
	coyoteTime_Timer.start(coyote_time)
	

func _stop_coyote_time():
	if coyoteTime_Timer.is_stopped():
		return
	
	coyoteTime_Timer.stop()
	hasCoyoteTime = true
	

func _invalidate_coyote_time():
	hasCoyoteTime = true
	

func _handle_falling(delta: float):
		# Add the gravity.
		player.velocity.y += gravity * delta
		
		if !hasJumped && !hasCoyoteTime && coyoteTime_Timer.is_stopped():
			_start_coyote_time()
	

func try_jump():
	if !_is_jump_valid():
		jumpInput_Timer.start(jumpQueued_time)
		return
	
	_queue_jump()


func _queue_jump():
	hasJumped = true
	canJump = true

func _is_jump_valid():
	return !coyoteTime_Timer.is_stopped() || player.is_on_floor()
