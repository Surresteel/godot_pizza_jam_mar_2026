#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name RingTosserplayer
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# MOVEMENT:
static var sensitivity_mouse: float = 0.002
@onready var cam: Camera3D = $Cam
@onready var game_vector := -global_basis.z
var _limit_pitch: float = deg_to_rad(45)
var _limit_yaw: float = deg_to_rad(45)

# GAME:
@export var stand: RingStand = null
@export var pinhead: Pinhead = null
@onready var ring_spawn: Node3D = $RingSpawn
static var scene_ring := preload("uid://wtoyj5gndted")
static var charge_max: float = 10.0
var _rings: Array[Node3D]
var _cur_ring: RigidBody3D = null
var charging: bool = false
var charge: float = 0.0
var _max_throws: int = 5
var _cur_throw: int = 0
var has_won = false;


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Node initialisation:
func _ready() -> void:
	GameManager.game_change.connect(_on_game_change)
	_disable_node()
	if stand:
		stand.game_won.connect(_game_won)
	if pinhead:
		pinhead.ring_on.connect(_on_pinhead_restrained)


# Node processing:
func _process(_delta: float) -> void:
	# Update charge UI:
	UiManager.set_ring_power(charge / charge_max)
	
	# GATE - _cur_ring must exist:
	if not _cur_ring:
		return
	
	if _cur_ring.freeze:
		_cur_ring.global_position = ring_spawn.global_position


#===============================================================================
#	FUNCTIONS - LIFECYCLE:
#===============================================================================
# Handles node lifecycle as game state changes:
func _on_game_change(old: GameManager.GAME, new: GameManager.GAME) -> void:
	if new == GameManager.GAME.RING:
		_enable_node()
	elif old == GameManager.GAME.RING:
		_disable_node()
	return


# Enables the game:
func _enable_node() -> void:
	_cur_throw = 0
	has_won = false
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	UiManager.set_ring_count(_max_throws, _max_throws)
	_get_new_ring()
	cam.make_current()
	return


# Disables the game:
func _disable_node() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	#self.set_process_input(false)
	cam.clear_current()
	
	if has_won:
		if _rings.size() > 0:
			_rings[_rings.size()-1].queue_free()
		return
	
	# Clean up rings:
	for ring in _rings:
		if ring:
			ring.queue_free()
	_rings.clear()
	
	return


func _game_won() -> void:
	has_won = true
	print("Game won")
	GameManager.switch_game(GameManager.GAME.NONE)


# Ends the game:
func _game_lose() -> void:
	print("Game lost")
	GameManager.switch_game(GameManager.GAME.NONE)


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
	
	return


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
	
	# Apply impulse:
	_cur_ring.freeze = false
	_cur_ring.apply_central_impulse(axis * charge)
	_cur_ring = null
	
	# Tally throw:
	charge = 0.0
	_cur_throw += 1
	UiManager.set_ring_count(_max_throws - _cur_throw, _max_throws)
	
	# Timeout and get new ring, or exit if max throws reached:
	if _cur_throw == _max_throws and not has_won:
		await get_tree().create_timer(2).timeout
		_game_lose()
	else:
		await get_tree().create_timer(1).timeout
		_get_new_ring()
	
	return


# Gets a new ring for the player:
func _get_new_ring() -> void:
	# GATE - node must be enabled:
	if self.process_mode == Node.PROCESS_MODE_DISABLED:
		return
	
	_cur_ring = scene_ring.instantiate()
	
	# GATE - _cur_ring must exist:
	if not _cur_ring:
		return
	
	# Add ring to scene:
	get_tree().current_scene.add_child(_cur_ring)
	_cur_ring.freeze = true
	_cur_ring.add_to_group("rings")
	_cur_ring.global_position = ring_spawn.global_position
	_rings.append(_cur_ring)
	
	return


func _on_pinhead_restrained() -> void:
	print("Pinhead dead!")
	await get_tree().create_timer(4).timeout
	_game_won()


#===============================================================================
#	FUNCTIONS - INPUT:
#===============================================================================
# Handles input events for aiming:
func _unhandled_input(event: InputEvent) -> void:
	# Exit game if cancel pressed:
	if event.is_action_pressed("cancel"):
		GameManager.switch_game(GameManager.GAME.NONE)
	
	# Throw ring if criteria met:
	if charging and event.is_action_released("hit"):
		_throw_ring()
		charging = false
		return
	
	# GATE - input event must be mouse motion:
	if event is not InputEventMouseMotion:
		return
	
	# Aim / charge ring:
	if Input.is_action_pressed("hit") and _cur_ring:
		charging = true
		charge -= event.relative.y * 0.01
		charge = clampf(charge, 0.0, charge_max)
	else:
		var hor: float = sensitivity_mouse * -event.relative.x
		var vert: float = sensitivity_mouse * -event.relative.y
		_rotate(hor, vert)
	
	return
