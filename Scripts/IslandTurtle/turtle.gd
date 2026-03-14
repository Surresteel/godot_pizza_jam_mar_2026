#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Turtle
extends CharacterBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================

# IDENTITY:
@export var turtle_name: String = ""

# COLLISION:
static var rest_coef: float = 0.9
@onready var area: Area3D = $Area
var pending_collision := Vector3.ZERO
var mass: float = 5.0

# MOVEMENT:
var allow_move: bool = true
var acceleration: float = 1.5
var speed: float = 0.5
var mouse_intercept := Vector3.ZERO


#===============================================================================
#	CALLBACKS:
#===============================================================================

# Initialise node:
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)


# Update node:
func _physics_process(delta: float) -> void:
	_update_mouse_intercept()
	_update_direction()
	_update_velocity(delta)
	_dampen_movement(delta)
	_apply_gravity(delta)
	
	if not pending_collision.is_zero_approx():
		_apply_pending_collision()
	
	move_and_slide()


#===============================================================================
#	FUNCTIONS MOVEMENT:
#===============================================================================

# Applies gravity to the turtle:
func _apply_gravity(delta: float) -> void:
	# GATE - Turtle must be in air:
	if is_on_floor():
		return
	
	# Apply gravity:
	velocity += get_gravity() * delta
	
	return

# Handles the turtle's looking direction:
func _update_direction() -> void:
	# GATE - turtle must be on floor to look around:
	if not is_on_floor():
		return
	
	# Calculate new basis:
	var pos = mouse_intercept - global_position
	var floor_norm: Vector3 = get_floor_normal()
	#var new_basis: Basis = Basis.looking_at(mouse_intercept, floor_norm)
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


# Update the velocity of the turtle:
func _update_velocity(delta: float) -> void:
	# GATE - turtle must be on floor to look around:
	if not is_on_floor():
		return
	
	# GATE - turtle must be allowed to move:
	if not allow_move:
		return
	
	# Update velocity:
	var new_vel = (-transform.basis.z * acceleration * delta)
	if (velocity + new_vel).length_squared() > speed * speed:
		return
		#new_vel.limit_length(maxf(0.0, speed - velocity.length()))
	velocity += new_vel
	
	return


# Dampens turtle movement in uncommanded directions:
func _dampen_movement(delta: float) -> void:
	# Get 2D velocity:
	var vel_2d: Vector3 = velocity
	vel_2d.y = 0
	
	# GATE - If turtle is approximately static, stop the turtle:
	if vel_2d.is_zero_approx():
		velocity.x = 0
		velocity.z = 0
		return
	
	# Get the portion of the turtle's velocity opposing their movement:
	var fwd: Vector3 = -global_basis.z
	var vel_dot: float = vel_2d.dot(fwd)
	var vel_obtuse: bool = fwd.is_zero_approx() or vel_dot < 0.0
	var dampen_dir := -vel_2d if vel_obtuse\
			else -(vel_2d - fwd * vel_dot)
	dampen_dir.y = 0.0
	
	# Dampen that portion:
	dampen_dir = dampen_dir.limit_length(1.0)
	velocity += dampen_dir * acceleration * delta
	
	return


# Applies the pending collision force:
func _apply_pending_collision() -> void:
	velocity += pending_collision
	pending_collision = Vector3.ZERO


#===============================================================================
#	FUNCTIONS COLLISION:
#===============================================================================

# Processes collisions with other turtles:
func _on_body_entered(other_node: Node3D) -> void:
	# GATE - detected node must not be self:
	if other_node == self:
		return
	
	# GATE - other node must be a turtle:
	print(turtle_name)
	if other_node is not Turtle:
		print("not a turtle")
		return
	var other_turtle := other_node as Turtle
	
	# Get relative velocities:
	var normal = (other_turtle.global_position - global_position).normalized()
	var relative_velocity = velocity - other_turtle.velocity
	var collision_speed = relative_velocity.dot(normal)
	
	# GATE - collision velocity must be positive:
	print(collision_speed)
	if collision_speed < 0:
		print("no collision speed")
		return
	
	# Calculate impulse:
	var other_mass: float = other_turtle.mass
	var impulse_magnitude = -(1 + rest_coef) * collision_speed
	impulse_magnitude /= (1 / mass + 1 / other_mass)
	
	# Apply force:
	var impulse_vector = impulse_magnitude * normal * 2.0
	print(impulse_magnitude)
	pending_collision = impulse_vector / mass
	
	return
