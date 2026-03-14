#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name TurtleAi
extends Turtle


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================

# TARGETING:
var target: Turtle = null
var switch_cooldown: int = 1000
var switch_timeout: int = 0


#===============================================================================
#	CALLBACKS:
#===============================================================================

# Initialise node:
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	add_to_group("turtles")


# Update node:
func _physics_process(delta: float) -> void:
	if not target or Time.get_ticks_msec() > switch_timeout:
		_update_target()
	
	if not target:
		return
	
	_update_direction(delta)
	_update_velocity(delta)
	_dampen_movement(delta)
	_apply_gravity(delta)
	
	if not pending_collision.is_zero_approx():
		_apply_pending_collision()
	
	move_and_slide()


#===============================================================================
#	FUNCTIONS MOVEMENT:
#===============================================================================

# Handles the turtle's looking direction:
func _update_direction(delta: float) -> void:
	# GATE - turtle must be on floor to look around:
	if not is_on_floor():
		return
	
	# Calculate new basis:
	var pos = target.global_position - global_position
	var floor_norm: Vector3 = get_floor_normal()
	var new_basis: Basis = Basis.looking_at(pos, floor_norm)
	
	# Convert to quaternions:
	var current_quat = transform.basis.get_rotation_quaternion()
	var target_quat = new_basis.get_rotation_quaternion()
	var angle_diff = current_quat.angle_to(target_quat)
	
	# GATE - angle must be sufficiently different:
	if angle_diff < 0.001:
		return
	
	# Apply basis slerp:
	var weight = min(1.0, (turn_rate * delta) / angle_diff)
	transform.basis = Basis(current_quat.slerp(target_quat, weight))
	#transform.basis = new_basis
	
	return


#===============================================================================
#	FUNCTIONS AI:
#===============================================================================
func _update_target() -> void:
	# Get turtles:
	var all_turtles: Array[Node] = get_tree().get_nodes_in_group("turtles")
	
	# GATE - must be at least one turtle to target:
	all_turtles.erase(self)
	if all_turtles.is_empty():
		return
	
	# Find nearest turtle:
	var nearest_turtle = Utils.get_nearest_node(global_position, all_turtles)
	
	# GATE - nearest turtle must exist:
	if not nearest_turtle:
		return
	
	# Update cooldown:
	switch_timeout = Time.get_ticks_msec() + switch_cooldown
	
	# Update target turtle:
	target = nearest_turtle
	return
