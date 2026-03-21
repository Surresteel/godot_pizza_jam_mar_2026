#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name TurtlePlayer
extends Turtle


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================

# MOVEMENT:
var mouse_intercept := Vector3.ZERO


#===============================================================================
#	CALLBACKS:
#===============================================================================

# Initialise node:
func _ready() -> void:
	_setup()


# Update node:
func _physics_process(delta: float) -> void:
	if is_dead:
		_dampen_movement(delta)
		move_and_slide()
		return
	
	_update_mouse_intercept()
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
func _update_direction(_delta: float) -> void:
	# GATE - turtle must be on floor to look around:
	if not is_on_floor():
		return
	
	# Calculate new basis:
	var pos = mouse_intercept - global_position
	var floor_norm: Vector3 = get_floor_normal()
	var new_basis: Basis = Basis.looking_at(pos, floor_norm)
	
	# Apply new basis:
	transform.basis = new_basis
	
	return


# Updates the mouse intercept point with the environment collision layer:
func _update_mouse_intercept() -> void:
	# Get mouse screen position:
	var mouse_pos := get_viewport().get_mouse_position()
	
	# Get ray start and end:
	var camera : Camera3D = get_viewport().get_camera_3d()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_end := ray_origin + camera.project_ray_normal(mouse_pos) * 1000.0
	
	# Perform raycast:
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = 16
	var space_state = get_world_3d().direct_space_state
	var result : Dictionary = space_state.intersect_ray(query)
	
	# Process result:
	if not result.is_empty():
		mouse_intercept = result.position
	
	return
	
