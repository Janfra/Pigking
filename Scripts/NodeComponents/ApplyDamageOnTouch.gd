class_name ApplyDamageOnTouch
extends Area2D
## Deals damage on overlap to nodes health

## Damage that will be dealt on start of overlap
@export var damage_on_touch:int = 1

## Check if overlap has health and remove health
func _on_body_entered(body):
	print("Body entered damage zone: %s" %body.name)
	var NodeHealth = HealthComponent.try_get_node_health(body)
	if NodeHealth:
		NodeHealth.remove_health_amount(damage_on_touch)
	
