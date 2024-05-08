extends Node
class_name Health

#region Static Getter and Setter
static var s_nodeToHealth:Dictionary
static func _RegisterNodeToHealth(Owner:Node, HealthNode:Health) -> void:
	if !Owner || s_nodeToHealth.has(Owner):
		printerr("%s is trying to registered invalid health owner" %Owner.name)
		return
	
	print("Registered node: %s" %Owner.name)
	s_nodeToHealth[Owner] = HealthNode
	

static func _UnRegisterNodeHealth(Owner:Node):
	if !Owner || !s_nodeToHealth.has(Owner):
		printerr("%s is trying to unregistered invalid health owner" %Owner.name)
		return
	
	print("Unregistered node: %s" %Owner.name)
	s_nodeToHealth.erase(Owner)
	

static func TryGetNodeHealth(Target:Node) -> Health:
	if !Target || !s_nodeToHealth.has(Target):
		return null
	
	return s_nodeToHealth[Target]
	

#endregion

#region Signals
signal OnHealthAdded(newHealth:int, ReducedBy:int)
signal OnHealthRemoved(newHealth:int, ReducedBy:int)
signal OnHealthRefilled(isRevive:bool)
signal OnHealthDepleted

#endregion

@export var maxHealth:int = 1:
	get:
		return maxHealth
	set(value):
		maxHealth = max(value, 0) 

@export var invulnerabilityTime:float = 0.2 

var health:int:
	get:
		assert(health > -1)
		return health
	set(value):
		value = max(value, 0)
		health = min(value, maxHealth)

var invulnerability_timer:Timer 

func _ready() -> void:
	health = maxHealth
	Health._RegisterNodeToHealth(owner, self)
	_setup_invulnerability_timer()
	

#INFO: Destructor equivalent
func _exit_tree():
	assert(owner, "No owner set on health node when exiting tree")
	Health._UnRegisterNodeHealth(owner)
	

func _setup_invulnerability_timer() -> void:
	invulnerability_timer = Timer.new()
	add_child(invulnerability_timer)
	invulnerability_timer.owner = owner
	invulnerability_timer.one_shot = true
	invulnerability_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	

func RemoveHealthAmount(value:int) -> void:
	if !invulnerability_timer.is_stopped(): 
		print("Tried to damage %s while invulnerable" %owner.name)
		return
	
	health -= value
	OnHealthRemoved.emit(health, value)
	invulnerability_timer.start(invulnerabilityTime)
	
	if health == 0:
		OnHealthDepleted.emit()
	
	print("Health after damage: %s - Max health: %s" % [health, maxHealth])
	

func AddHealthAmount(value:int) -> void:
	health += value
	OnHealthAdded.emit(health, value)
	
	print("Health after heal: %s - Max health: %s" % [health, maxHealth])
	

func SetHealthToMax(isRevive:bool = true) -> void:
	health = maxHealth
	OnHealthRefilled.emit(isRevive)
	
	print("Health reset")
	
