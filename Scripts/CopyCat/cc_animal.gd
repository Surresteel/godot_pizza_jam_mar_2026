#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name CCAnimal
extends CharacterBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# STATICS:
static var sizes: Dictionary = {s = 0.5, m = 1.0, l = 1.5}
static var combinations: Array[PackedFloat64Array]
static var count: int = 0

# IDENTITY:
var id: int = -1
var is_copycat: bool = false
var is_original: bool = false
var combination: PackedFloat64Array

# MOVEMENT:
var max_speed: float = 1.0
var max_turn: float = 3.0
var cur_dir := Vector3.FORWARD
var dir_timeout: int = 0
var dir_cd_low: int = 500
var dir_cd_high: int = 2000

# ANATOMY:
@onready var eye_l: Node3D = $Body/Head/EyeL
@onready var eye_r: Node3D = $Body/Head/EyeR
@onready var ear_l: Node3D = $Body/Head/EarL
@onready var ear_r: Node3D = $Body/Head/EarR
@onready var tail: Node3D = $Body/Tail

# ANIMATION:
var poof: PackedScene = preload("uid://cdjjluy1thota")


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Node initialisation:
func _ready() -> void:
	id = CCAnimal.count
	CCAnimal.count += 1


func _process(delta: float) -> void:
	_apply_gravity(delta)
	
	# Update movement:
	_update_direction(delta)
	_update_velocity()
	move_and_slide()
	
	# Change direction after timeout:
	if _check_dir_timeout():
		_set_next_dir()
		return
	
	return


# Removes this animal's combination from the static array on exit:
func _exit_tree() -> void:
	# GATE - must not be copycat:
	if is_copycat:
		return
	
	# Get combination in combinations:
	var idx: int = CCAnimal.combinations.find_custom(
				_same_traits.bind(combination))
	
	
	# GATE - combination must exist in static array:
	if idx != -1:
		combinations.remove_at(idx)


#===============================================================================
#	FUNCTIONS - LIFECYCLE:
#===============================================================================
func explode() -> void:
	var fx: GPUParticles3D = poof.instantiate()
	get_tree().current_scene.add_child(fx)
	fx.global_position = global_position
	
	self.queue_free()



#===============================================================================
#	FUNCTIONS - SETUP:
#===============================================================================
# Randomises the traits of the animal:
func randomise_traits() -> void:
	# Get unique trait combination:
	var eye_scale: float = sizes[sizes.keys().pick_random()]
	var ear_scale: float = sizes[sizes.keys().pick_random()]
	var tail_scale: float = sizes[sizes.keys().pick_random()]
	combination = [eye_scale, ear_scale, tail_scale]
	while combinations.find_custom(_same_traits.bind(combination)) != -1:
		eye_scale = sizes[sizes.keys().pick_random()]
		ear_scale = sizes[sizes.keys().pick_random()]
		tail_scale = sizes[sizes.keys().pick_random()]
		combination = [eye_scale, ear_scale, tail_scale]
	combinations.append(combination)
	
	# Set scales to match combination:
	eye_l.scale = Vector3(eye_scale, eye_scale, eye_scale)
	eye_r.scale = Vector3(eye_scale, eye_scale, eye_scale)
	ear_l.scale = Vector3(ear_scale, ear_scale, ear_scale)
	ear_r.scale = Vector3(ear_scale, ear_scale, ear_scale)
	tail.scale = Vector3(tail_scale, tail_scale, tail_scale)
	
	return


# Copies the traits
func copy_traits(animal: CCAnimal) -> void:
	# GATE - animal to copy must exist:
	if not animal:
		return
	
	# GATE - c must have three values:
	var c: PackedFloat64Array = animal.combination
	if c.size() != 3:
		return
	
	# Set animal to copycat:
	is_copycat = true
	
	# Assign traits:
	eye_l.scale = Vector3(c[0], c[0], c[0])
	eye_r.scale = Vector3(c[0], c[0], c[0])
	ear_l.scale = Vector3(c[1], c[1], c[1])
	ear_r.scale = Vector3(c[1], c[1], c[1])
	tail.scale = Vector3(c[2], c[2], c[2])


#===============================================================================
#	FUNCTIONS - MOVEMENT:
#===============================================================================
# Applies gravity to the turtle:
func _apply_gravity(delta: float) -> void:
	# GATE - animal must be in air:
	if is_on_floor():
		return
	
	# Apply gravity:
	velocity += get_gravity() * delta
	
	return

# Checks the timeout for the change of direction:
func _check_dir_timeout() -> bool:
	var now: int = Time.get_ticks_msec()
	if now < dir_timeout:
		return false
	
	dir_timeout = now + randi_range(dir_cd_low, dir_cd_high)
	return true


# Sets the next direction of travel for the mouse:
func _set_next_dir(override := Vector3.ZERO) -> void:
	# Set dir directly via override:
	if not override.is_zero_approx():
		cur_dir = override
		cur_dir.y = 0
		cur_dir = cur_dir.normalized()
		return
	
	# Set random direction:
	var rot: float = randf_range(-180, 180)
	rot = deg_to_rad(rot)
	cur_dir = -global_basis.z.rotated(Vector3.UP, rot)
	cur_dir.y = 0
	cur_dir = cur_dir.normalized()
	
	return


# Handles the animal's looking direction:
func _update_direction(delta: float) -> void:
	# GATE - batteryman must be on floor to look around:
	if not is_on_floor():
		return
	
	# Calculate new basis:
	var new_basis: Basis = Basis.looking_at(cur_dir, Vector3.UP)
	
	# Convert to quaternions:
	var current_quat = transform.basis.get_rotation_quaternion()
	var target_quat = new_basis.get_rotation_quaternion()
	var angle_diff = current_quat.angle_to(target_quat)
	
	# GATE - angle must be sufficiently different:
	if angle_diff < 0.001:
		return
	
	# Apply basis slerp:
	var weight = min(1.0, (max_turn * delta) / angle_diff)
	transform.basis = Basis(current_quat.slerp(target_quat, weight))
	
	return


# Update the velocity of batteryman:
func _update_velocity() -> void:
	# GATE - turtle must be on floor to move:
	if not is_on_floor():
		return
	
	# Update velocity:
	velocity = -transform.basis.z * max_speed
	
	return


#===============================================================================
#	FUNCTIONS - HELPERS:
#===============================================================================
# Determines whether two trait combinations are the same:
func _same_traits(c1: PackedFloat64Array, c2:PackedFloat64Array) -> bool:
	if c1.size() != 3 or c2.size() != 3:
		return false
	
	return c1[0] == c2[0] and c1[1] == c2[1] and c1[2] == c2[2]
