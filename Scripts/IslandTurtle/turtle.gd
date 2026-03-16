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

# AUDIO:
const SFX_HIT: AudioStreamWAV = preload("uid://cp7o3rcewyn7a")
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer

# COLLISION:
static var rest_coef: float = 0.9
@onready var area: Area3D = $Area
var pending_collision := Vector3.ZERO
var mass: float = 5.0

# MOVEMENT:
var allow_move: bool = true
var turn_rate: float = 3.0
var acceleration: float = 1.5
var speed: float = 0.5


#===============================================================================
#	FUNCTIONS - MOVEMENT:
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
func _update_direction(_delta: float) -> void:
	pass


# Update the velocity of the turtle:
func _update_velocity(delta: float) -> void:
	# GATE - turtle must be on floor to move:
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
#	FUNCTIONS - COLLISION:
#===============================================================================

# Processes collisions with other turtles:
func _on_body_entered(other_node: Node3D) -> void:
	# GATE - detected node must not be self:
	if other_node == self:
		return
	
	# GATE - other node must be a turtle:
	if other_node is not Turtle:
		return
	var other_turtle := other_node as Turtle
	
	# Get relative velocities:
	var normal = (other_turtle.global_position - global_position).normalized()
	var relative_velocity = velocity - other_turtle.velocity
	#var collision_speed = relative_velocity.dot(normal)
	var collision_speed = maxf(relative_velocity.dot(normal), 0.5)
	
	# GATE - collision velocity must be positive:
	if collision_speed < 0:
		return
	
	# Calculate impulse:
	var other_mass: float = other_turtle.mass
	var impulse_magnitude = -(1 + rest_coef) * collision_speed
	impulse_magnitude /= (1 / mass + 1 / other_mass)
	
	# Apply force:
	var impulse_vector = impulse_magnitude * normal * 2.0
	pending_collision = impulse_vector / mass
	
	# Play sound:
	_play_audio(SFX_HIT)
	
	return


#===============================================================================
#	FUNCTIONS - ANIMATIONS:
#===============================================================================
# TODO: Add animations:
#func _play_anim(anim: String, blend: float = 1, speed: float = 1.0) -> void:
	#_anim_player.play(anim, blend, speed)
	#_anim_player.queue("Swimming")


#===============================================================================
#	FUNCTIONS - AUDIO:
#===============================================================================
# Plays an audio resource from the turtle:
func _play_audio(resource, override: bool = true) -> void:
	# GATE - must not be playing if override disabled:
	if not override and audio_player.playing:
		return
	
	# Play audio:
	audio_player.stream = resource
	audio_player.play()
	
	return
