#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name RingTosserplayer
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================

# DEBUG:
var show_cursor: bool = false

# MOVEMENT:
static var sensitivity_mouse: float = 0.002
@onready var game_vector := -global_basis.z
var _limit_pitch: float = deg_to_rad(45)
var _limit_yaw: float = deg_to_rad(45)

# GAME:
@onready var ring_spawn: Node3D = $RingSpawn
static var scene_ring := preload("uid://wtoyj5gndted")
var _cur_ring: RigidBody3D = null
var charging: bool = false
var charge: float = 0.0

#===============================================================================
#	CALLBACKS:
#===============================================================================

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	call_deferred("_ready_deferred")


func _ready_deferred() -> void:
	_get_new_ring()


func _process(_delta: float) -> void:
	if not _cur_ring:
		return
	
	if _cur_ring.freeze:
		_cur_ring.global_position = ring_spawn.global_position


#===============================================================================
#	FUNCTIONS - MOVEMENT:
#===============================================================================

# Rotates the character based on hor and vert radians:
func _rotate(hor: float, vert: float) -> void:
	# Get flat forward:
	var fwd = -global_basis.z
	fwd.y = 0
	fwd = fwd.normalized()
	
	# Ensure the vertical look angle is within limits:
	var angle_ver := (-global_basis.z).signed_angle_to(fwd, -global_basis.x)
	if angle_ver + vert > _limit_pitch:
		vert = _limit_pitch - angle_ver
	if angle_ver + vert < -_limit_pitch:
		vert = -_limit_pitch - angle_ver
	
	# Ensure the horizontal look angle is within limits:
	var angle_hor := (fwd).signed_angle_to(game_vector, 
			Vector3.UP)
	var target_hor = clamp(angle_hor - hor, -_limit_yaw, _limit_yaw)
	hor = -(target_hor - angle_hor)
	
	# Rotate body:
	rotate_y(hor)
	rotate_object_local(Vector3.RIGHT, vert)


#===============================================================================
#	FUNCTIONS - GAME:
#===============================================================================

# Throws the current ring:
func _throw_ring() -> void:
	# GATE - _cur_ring must exist:
	if not _cur_ring:
		return
	
	# Get impulse axis:
	var axis: Vector3 = -global_basis.z
	axis = axis.rotated(global_basis.x, deg_to_rad(40))
	
	_cur_ring.freeze = false
	_cur_ring.apply_central_impulse(axis * charge)
	_cur_ring = null
	
	# Timeout and get new ring:
	await get_tree().create_timer(1).timeout
	_get_new_ring()


# Gets a new ring for the player:
func _get_new_ring() -> void:
	_cur_ring = scene_ring.instantiate()
	
	if not _cur_ring:
		return
	
	get_tree().current_scene.add_child(_cur_ring)
	_cur_ring.freeze = true
	_cur_ring.add_to_group("rings")
	_cur_ring.global_position = ring_spawn.global_position


#===============================================================================
#	FUNCTIONS - INPUT:
#===============================================================================

# Handles input events for aiming:
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_1"):
		if show_cursor:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			show_cursor = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			show_cursor = true
	
	# Throw ring if criteria met:
	if charging and event.is_action_released("hit"):
		_throw_ring()
		charging = false
		return
	
	# GATE - input event must be mouse motion:
	if event is not InputEventMouseMotion:
		return
	
	# Aim / charge ring:
	if Input.is_action_pressed("hit"):
		charging = true
		charge -= event.relative.y * 0.01
	else:
		var hor: float = sensitivity_mouse * -event.relative.x
		var vert: float = sensitivity_mouse * -event.relative.y
	
		_rotate(hor, vert)
