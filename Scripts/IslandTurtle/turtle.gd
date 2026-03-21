#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Turtle
extends CharacterBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# ANIMATION:
@onready var _anim_player: AnimationPlayer = \
		$TurtleRigged/AnimationPlayer

# IDENTITY:
@export var turtle_name: String = ""
@export var colour := Color.RED

# MATERIAL:
@onready var shell: MeshInstance3D = $TurtleRigged/Armature/Skeleton3D/Turtle

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

# GAMEPLAY:
var is_dead: bool = false
var hit_rand_max: float = 1.2
var hit_rand_min: float = 0.8


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
#	FUNCTIONS - GAMEPLAY:
#===============================================================================
func _setup() -> void:
	area.body_entered.connect(_on_body_entered)
	
	# Set turtle colour:
	var mat: StandardMaterial3D = shell.get_active_material(0)
	mat.albedo_color = colour
	
	# Start animation:
	_anim_player.animation_finished.connect(_queue_walk)
	_play_anim("Walk", 1.0, 5.0)


func kill() -> void:
	is_dead = true
	remove_from_group("turtles")
	_anim_player.play("Flipped", 1, 1)


func won() -> void:
	_anim_player.play("Victory", 1, 1)


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
	var rand_mod = randf_range(hit_rand_min, hit_rand_max)
	var impulse_vector = impulse_magnitude * normal * 2.0 * rand_mod
	pending_collision = impulse_vector / mass
	
	# Play sound and animation:
	_play_audio(SFX_HIT)
	_play_anim("Hit")
	
	return


#===============================================================================
#	FUNCTIONS - ANIMATIONS:
#===============================================================================
func _play_anim(anim: String, blend: float = 1, play_spd: float = 1.0) -> void:
	_anim_player.play(anim, blend, play_spd)
	#_anim_player.queue("Walk")


func _queue_walk(_anim: String) -> void:
	if is_dead:
		return
	
	_play_anim("Walk", 1.0, 5.0)


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
