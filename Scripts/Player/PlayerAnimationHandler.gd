extends RefCounted

class_name PlayerAnimationHandler

var animated_sprite:AnimatedSprite2D
var override_input:bool = false

func _init(animator: AnimatedSprite2D):
	animated_sprite = animator
	if !animated_sprite:
		print("No animation sprite set on player animation handler")
	else:
		print("Player animation handler initialized")

func handle_movement_animations(velocity: Vector2, input: Vector2, latest_valid_input: Vector2):
	if !animated_sprite:
		return
	
	_set_facing_direction(latest_valid_input)
	_animate_sideways_movement(velocity, input)
	_animate_falling(velocity)

func _set_facing_direction(input : Vector2):
	animated_sprite.flip_h = input.x < 0

func _animate_sideways_movement(velocity: Vector2, input : Vector2):
	var isMoving = velocity.x != 0
	if !isMoving:
		animated_sprite.play("Idle")
		return
	
	# Just in case player is pushed by non-input
	var isInputMovement = input.x != 0
	if !override_input && isInputMovement:
		animated_sprite.play("Walking")
	

func _animate_falling(velocity: Vector2):
	if velocity.y > 0:
		animated_sprite.play("Falling")
	elif velocity.y < 0:
		animated_sprite.play("Jumping")