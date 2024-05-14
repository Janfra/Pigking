class_name HealthComponent
extends Node
## Handles health and health related states of node

#region Static Getter and Setter
static var s_node_to_health:Dictionary
static func _register_node_to_health(Owner:Node, HealthNode:HealthComponent) -> void:
	if !Owner || s_node_to_health.has(Owner):
		printerr("%s is trying to registered invalid health owner" %Owner.name)
		return
	
	print("Registered node: %s" %Owner.name)
	s_node_to_health[Owner] = HealthNode
	

static func _unregister_node_health(Owner:Node):
	if !Owner || !s_node_to_health.has(Owner):
		printerr("%s is trying to unregistered invalid health owner" %Owner.name)
		return
	
	print("Unregistered node: %s" %Owner.name)
	s_node_to_health.erase(Owner)
	

static func try_get_node_health(Target:Node) -> HealthComponent:
	if !Target || !s_node_to_health.has(Target):
		return null
	
	return s_node_to_health[Target]
	

#endregion

#region Signals
signal on_health_added(newHealth:int, ReducedBy:int)
signal on_health_removed(newHealth:int, ReducedBy:int)
signal on_health_refilled(isRevive:bool)
signal on_health_depleted

#endregion

#region Exported Variables
@export var max_health:int = 1:
	get:
		return max_health
	set(value):
		max_health = max(value, 0) 

@export var invulnerability_time:float = 0.2 
#endregion

#region Internal Variables
var health:int:
	get:
		assert(health > -1)
		return health
	set(value):
		value = max(value, 0)
		health = min(value, max_health)

var invulnerability_timer:Timer 
#endregion

func _ready() -> void:
	health = max_health
	HealthComponent._register_node_to_health(owner, self)
	_setup_invulnerability_timer()
	

#INFO: Destructor equivalent
func _exit_tree():
	assert(owner, "No owner set on health node when exiting tree")
	HealthComponent._unregister_node_health(owner)
	

func _setup_invulnerability_timer() -> void:
	invulnerability_timer = Timer.new()
	add_child(invulnerability_timer)
	invulnerability_timer.owner = owner
	invulnerability_timer.one_shot = true
	invulnerability_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	

func remove_health_amount(value:int) -> void:
	if !invulnerability_timer.is_stopped(): 
		print("Tried to damage %s while invulnerable" %owner.name)
		return
	
	health -= value
	on_health_removed.emit(health, value)
	invulnerability_timer.start(invulnerability_time)
	
	if health == 0:
		on_health_depleted.emit()
	
	print("Health after damage: %s - Max health: %s" % [health, max_health])
	

func add_health_amount(value:int) -> void:
	health += value
	on_health_added.emit(health, value)
	
	print("Health after heal: %s - Max health: %s" % [health, max_health])
	

func set_health_to_max(isRevive:bool = true) -> void:
	health = max_health
	on_health_refilled.emit(isRevive)
	
	print("Health reset")
	
