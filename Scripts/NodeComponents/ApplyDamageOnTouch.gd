extends Area2D
class_name ApplyDamageOnTouch

@export var damageOnTouch:int = 1

func _on_body_entered(body):
	print("Body entered damage zone: %s" %body.name)
	var NodeHealth = Health.TryGetNodeHealth(body)
	if NodeHealth:
		NodeHealth.RemoveHealthAmount(damageOnTouch)
	
