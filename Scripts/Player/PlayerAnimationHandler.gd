extends Node
class_name PlayerAnimationHandler

const IDLE_ANIMATION = "Idle"
const WALKING_ANIMATION = "Walking"
const FALLING_ANIMATION = "Falling"
const JUMP_ANIMATION = "Jumping"

@export_group("Animations")
@export var animated_sprite:AnimatedSprite2D
@export var spriteXOffsetOnFlip:float
@export var walk_particles:GPUParticles2D
var override_input:bool = false

func handle_movement_animations(velocity: Vector2, input: Vector2, latestValidInput: Vector2) -> void:
	if !animated_sprite:
		return
	
	_set_facing_direction(latestValidInput)
	_animate_sideways_movement(velocity, input)
	_animate_falling(velocity)

func _set_facing_direction(input : Vector2) -> void:
	var isSpriteFlipped = input.x < 0
	animated_sprite.flip_h = isSpriteFlipped
	
	if isSpriteFlipped:
		animated_sprite.offset.x = spriteXOffsetOnFlip
	else:
		animated_sprite.offset.x = 0.0
	

func _animate_sideways_movement(velocity: Vector2, input : Vector2) -> void:
	var isMoving = velocity.x != 0
	if !isMoving:
		animated_sprite.play(IDLE_ANIMATION)
		return
	
	# Just in case player is pushed by non-input
	var isInputMovement = input.x != 0
	if !override_input && isInputMovement:
		animated_sprite.play(WALKING_ANIMATION)
	

func _animate_falling(velocity: Vector2) -> void:
	if velocity.y > 0:
		animated_sprite.play(FALLING_ANIMATION)
	elif velocity.y < 0:
		animated_sprite.play(JUMP_ANIMATION)
