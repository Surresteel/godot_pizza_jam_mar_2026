#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name BatteryHammer
extends AnimatableBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# AUDIO:
#const SFX_SHAKE: AudioStreamWAV = TBD
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer

# ORIENTATION:
@export var cam: Camera3D = null
@export var target: Node3D = null
@export var alignPoint: Node3D = null

# STATS:
@export var weight_multi: float = 0.8

# INPUT AND MOVEMENT:
@export var mouse_warp: float = 0.55
@export var speed: float = 20.0
var pos_prev := Vector3.ZERO
var vel_history: PackedVector3Array
var cur_idx: int = 0


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Node initialisation:
func _ready() -> void:
	pos_prev = global_position
	vel_history.resize(10)
	sync_to_physics = false
	# DEBUG:
	self.process_mode = Node.PROCESS_MODE_DISABLED
	self.visible = false
	GameManager.game_change.connect(_on_game_change)


func _process(delta: float) -> void:
	# GATE - target and alignPoint can't be the same:
	if target.global_position.is_equal_approx(alignPoint.global_position):
		return
	
	_align_hammer(delta)
	_update_velocity_history(delta)


#===============================================================================
#	FUNCTIONS - LIFECYCLE:
#===============================================================================
# Handles node lifecycle as game state changes:
func _on_game_change(_old: GameManager.GAME, new: GameManager.GAME) -> void:
	if new == GameManager.GAME.HAMMER:
		print("hammer enabled")
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		self.process_mode = Node.PROCESS_MODE_INHERIT
		self.visible = true
		cam.make_current()
	else:
		print("hammer disabled")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		self.process_mode = Node.PROCESS_MODE_DISABLED
		self.visible = false
		cam.clear_current()


#===============================================================================
#	FUNCTIONS - INPUT:
#===============================================================================
# Exits the hammer game:
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		GameManager.switch_game(GameManager.GAME.NONE)


#===============================================================================
#	FUNCTIONS - MOVEMENT:
#===============================================================================
# Aligns the hammer handle with the alignPoint
func _align_hammer(delta: float) -> void:
	# Update hammer position:
	var new_pos: Vector3 = _get_sphere_intersect()
	var vec_to = new_pos - global_position
	move_and_collide(vec_to * delta * speed)
	#global_position = _get_sphere_intersect()
	
	# Generate new global axes:
	var new_y = -(alignPoint.global_position - global_position).normalized()
	var temp_up = Vector3.UP if abs(new_y.dot(Vector3.UP)) < 0.99 \
			else Vector3.FORWARD
	var new_x = temp_up.cross(new_y).normalized()
	var new_z = new_x.cross(new_y).normalized()
	
	# Create basis from axes:
	global_basis = Basis(new_x, new_y, new_z)
	
	return


# Updates the history of the hammer's velocity:
func _update_velocity_history(delta: float) -> void:
	# ASSERT - vel_history must have at least 1 element:
	assert(vel_history.size() > 0, 
			"_update_velocity_history(): vel_history is empty.")
	
	# Add latest velocity to history:
	var new_vel = global_position - pos_prev
	pos_prev = global_position
	vel_history[cur_idx] = new_vel / delta
	cur_idx = (cur_idx + 1) % vel_history.size()


# Returns the average velocity of the hammer over the last five frames:
func get_velocity_average() -> Vector3:
	var sum := Vector3.ZERO
	for vel in vel_history:
		sum += vel
	
	return sum / vel_history.size()


# Returns the average velocity of the hammer over the last five frames:
func get_velocity_highest() -> Vector3:
	var highest := Vector3.ZERO
	for vel in vel_history:
		if vel.length_squared() > highest.length_squared():
			highest = vel
	
	return highest


#===============================================================================
#	FUNCTIONS - HELPERS:
#===============================================================================
# Applies a non-linear warp to the mouse pos in screen space:
func _get_warped_mouse_pos() -> Vector2:
	# Get mouse pos and viewport size:
	var viewport_size = get_viewport().get_visible_rect().size
	var raw_mouse = get_viewport().get_mouse_position()
	
	# Normalise mouse pos between -1 and 1:
	var centered_x = (raw_mouse.x / viewport_size.x) * 2.0 - 1.0
	
	# Apply non-linear function:
	var sens_power = mouse_warp
	var warped_x = sign(centered_x) * pow(abs(centered_x), sens_power)
	
	# Un-normalise mouse pos and return:
	var final_x = ((warped_x + 1.0) / 2.0) * viewport_size.x
	return Vector2(final_x, raw_mouse.y)


# Gets the intercept of the mouse position onto the inside of a sphere:
func _get_sphere_intersect() -> Vector3:
	# ASSERT - cam must exist:
	assert(cam, "_get_sphere_intersect(): cam is null")
	
	# ASSERT - cam must be within radius of alignPoint:
	var radius = (target.global_position - alignPoint.global_position).length()
	assert((cam.global_position - alignPoint.global_position).length() < radius, 
			"_get_sphere_intersect(): cam not within radius of alignPoint")
	
	# Get mouse ray origin and direction:
	var mouse_pos = _get_warped_mouse_pos()
	var origin = cam.project_ray_origin(mouse_pos)
	var direction = cam.project_ray_normal(mouse_pos)
	
	# Quadratic Solver:
	var oc = origin - alignPoint.global_position
	var a = direction.dot(direction)
	var b = 2.0 * oc.dot(direction)
	var c = oc.dot(oc) - radius**2
	var discriminant = b**2 - 4*a*c
	
	# Calculate and return descripinant:
	var t = (-b + sqrt(discriminant)) / (2.0 * a)
	return origin + (direction * t)
