class_name PlayerJumpHandler
extends Node

const MINIMUM_GRAVITY_MULTIPLIER = 0.01

#region Editable Variables
@export_group("Jump")
@export_subgroup("Dependencies")
@export var player:CharacterBody2D

@export_subgroup("Velocity")
@export var jump_velocity:float = -300.0
@export var jump_cut_multiplier:float = 0.2

@export_subgroup("Falling Speed")
@export var falling_gravity_multiplier:float = 1
@export var ascending_gravity_multiplier:float = 1
@export var down_input_gravity_multiplier:float = 1.2
@export var max_fall_speed:float = 300

@export_subgroup("Grace Timers")
@export var coyote_time:float = 0.2
@export var jump_queued_time:float = 0.2
#endregion

#region Logic booleans
# INFO: Has coyote time already being applied
var has_coyote_time:bool = false

# INFO: Has the player already jumped
var has_jumped:bool = false

# INFO: Is the player able to perform a jump
var can_jump:bool = false

# INFO: Can jump cut be performed
var can_jump_cut:bool = false

var is_falling:bool = false

var is_down_input:bool = false
#endregion

# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_time_timer:Timer 
var jump_input_timer:Timer

#region Warning Check
func _get_configuration_warnings():
	if !player:
		return ["No player set for jumping"]
	
	return []
#endregion

func try_jump() -> void:
	if !_is_jump_valid():
		jump_input_timer.start(jump_queued_time)
		return
	
	_queue_jump()

func try_jump_cut() -> void:
	if !can_jump || !can_jump_cut:
		return
	
	_cut_jump()
	

func increase_fall_speed(isInput:bool) -> void:
	is_down_input = isInput
	

#region Init
func _init() -> void:
	_setup_coyote_time_timer()
	_setup_jump_input_timer()
	update_configuration_warnings()
	

func _ready() -> void:
	assert(player, "Add player reference to player jump handler")
	

func _setup_coyote_time_timer() -> void:
	coyote_time_timer = Timer.new()
	add_child(coyote_time_timer)
	coyote_time_timer.owner = owner
	coyote_time_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	coyote_time_timer.one_shot = true
	coyote_time_timer.timeout.connect(self._invalidate_coyote_time.bind())
	

func _setup_jump_input_timer() -> void:
	jump_input_timer = Timer.new()
	add_child(jump_input_timer)
	jump_input_timer.owner = owner
	jump_input_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	jump_input_timer.one_shot = true
	
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
	 
	if(!jump_input_timer.is_stopped() && _is_jump_valid()):
		_queue_jump()
	

func _handle_off_ground(delta: float) -> void:
	is_falling = player.velocity.y > 0
	_apply_gravity(delta)
	
	if is_falling:
		can_jump_cut = false
		_clamp_fall_speed()
	
	if _should_coyote_time_start():
		_start_coyote_time()
	

func _handle_landing() -> void:
	has_jumped = false
	has_coyote_time = false
	can_jump_cut = true
	can_jump = true
	_stop_coyote_time()
	

#endregion

#region Falling Speed / Gravity

func _clamp_fall_speed() -> void:
	player.velocity.y = min(max_fall_speed, player.velocity.y)

func _apply_gravity(delta:float) -> void:
	if is_down_input:
		player.velocity.y += (gravity * down_input_gravity_multiplier) * delta
	else:
		if is_falling:
			player.velocity.y += (gravity * falling_gravity_multiplier) * delta
		else:
			player.velocity.y += (gravity * ascending_gravity_multiplier) * delta
	

#endregion

#region Jump logic
func _jump() -> void:
	player.velocity.y = 0
	player.velocity.y += jump_velocity
	can_jump = false
	has_jumped = true

func _cut_jump() -> void:
	player.velocity.y -= player.velocity.y * (1 - jump_cut_multiplier)
	can_jump_cut = false
	

func _is_jump_queued() -> bool:
	return has_jumped && can_jump

func _queue_jump() -> void:
	has_jumped = true
	can_jump = true
	jump_input_timer.stop()

func _is_jump_valid() -> bool:
	return !coyote_time_timer.is_stopped() || player.is_on_floor()
#endregion

#region Coyote Time
func _should_coyote_time_start() -> bool:
	return !has_jumped && !has_coyote_time && coyote_time_timer.is_stopped()

func _start_coyote_time() -> void:
	coyote_time_timer.start(coyote_time)
	

func _stop_coyote_time() -> void:
	if coyote_time_timer.is_stopped():
		return
	
	coyote_time_timer.stop()
	has_coyote_time = true
	

func _invalidate_coyote_time() -> void:
	has_coyote_time = true
	
#endregion
