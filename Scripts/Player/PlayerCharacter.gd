extends CharacterBody2D

# Constants
const SPEED = 170.0
const JUMP_VELOCITY = -300.0
const SPEED_SLOWDOWN_MULTIPLIER = 0.3
const COYOTE_TIME = 0.2

# References
@onready var animation_Handler:PlayerAnimationHandler = PlayerAnimationHandler.new(%AnimatedSprite2D)
var coyoteTime_Timer:Timer 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")	
var isCoyoteTime:bool = false
var hasJumped:bool = false
var hasCoyoteTime:bool = false
var input:Vector2 
var last_Valid_Input:Vector2 

func _init():
	_setup_coyote_time_timer()
	

func _setup_coyote_time_timer():
	coyoteTime_Timer = Timer.new()
	add_child(coyoteTime_Timer)
	coyoteTime_Timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	coyoteTime_Timer.one_shot = true
	coyoteTime_Timer.timeout.connect(self._invalidate_coyote_time.bind())
	

func _physics_process(delta):
	if not is_on_floor():
		_handle_falling(delta)
	else:
		hasJumped = false
		hasCoyoteTime = false
		_stop_coyote_time()
	
	_try_handle_jump()
	_handle_sideways_movement()
	
	animation_Handler.handle_movement_animations(velocity, input, last_Valid_Input)
	move_and_slide()
	

func _handle_falling(delta: float):
		# Add the gravity.
		velocity.y += gravity * delta
		
		if !hasJumped && !hasCoyoteTime && coyoteTime_Timer.is_stopped():
			_start_coyote_time()
		

func _try_handle_jump():
	if !isCoyoteTime && !is_on_floor():
		return
	
		# Handle jump.
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		input.y = 1
		hasJumped = true
	else:
		input.y = 0
	last_Valid_Input.y = input.y
	

func _handle_sideways_movement():
		# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input.x = Input.get_axis("move_left", "move_right")
	
	if input.x != 0:
		velocity.x = input.x * SPEED
		last_Valid_Input.x = input.x
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * SPEED_SLOWDOWN_MULTIPLIER)
	

func _start_coyote_time():
	coyoteTime_Timer.start(COYOTE_TIME)
	isCoyoteTime = true
	print("started coyote time")
	

func _stop_coyote_time():
	if coyoteTime_Timer.is_stopped():
		return
	
	print("stopped coyote time")
	coyoteTime_Timer.stop()
	isCoyoteTime = false
	hasCoyoteTime = true
	

func _invalidate_coyote_time():
	isCoyoteTime = false
	hasCoyoteTime = true
	print("invalidated coyote time")
	
