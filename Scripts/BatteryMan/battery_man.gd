#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name BatteryMan
extends CharacterBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# ANIMATION:
@onready var _anim_player: AnimationPlayer = \
		$BatteryManAnimationsDone/AnimationPlayer

# AUDIO:
const SFX_HIT: AudioStreamWAV = preload("uid://dbhjs0rmy65cb")
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer

# INTERACTABLE:
@onready var interactable: Interactable = $Interactable

# GAMEPLAY:
enum STATE {IDLE, MOVE_GAME, MOVE_IDLE, GAME}
var cur_state := STATE.IDLE
@export var node_game: Node3D
@export var node_idle: Node3D
@export var game: BatteryGame = null
var game_ongoing: bool = false
var state_change: bool = false

# MOVEMENT:
@export var speed: float = 2.0
@export var turn_rate: float = 6.0


#===============================================================================
#	CALLBACKS:
#===============================================================================

# Node initialisation:
func _ready() -> void:
	interactable.activated.connect(_activate_game)
	GameManager.game_change.connect(_on_game_change)
	cur_state = STATE.MOVE_IDLE
	_anim_player.animation_finished.connect(_return_to_idle)
	state_change = true


func _process(delta: float) -> void:
	match cur_state:
		STATE.IDLE:
			if state_change:
				_play_anim("HammerIdle")
				global_basis = node_idle.global_basis
				state_change = false
		STATE.MOVE_GAME:
			if state_change:
				_play_anim("Walk")
				state_change = false
				
			_apply_gravity(delta)
			if _go_to_point(delta, node_game.global_position):
				cur_state = STATE.GAME
				state_change = true
		STATE.MOVE_IDLE:
			if state_change:
				_play_anim("Walk")
				state_change = false
			
			_apply_gravity(delta)
			if _go_to_point(delta, node_idle.global_position):
				cur_state = STATE.IDLE
				state_change = true
		STATE.GAME:
			if state_change:
				global_basis = node_game.global_basis
				game_ongoing = true
				state_change = false
				_play_game()
			
			if not game_ongoing:
				cur_state = STATE.MOVE_IDLE
				state_change = true


#===============================================================================
#	FUNCTIONS - GAME:
#===============================================================================

func _on_game_change(old: GameManager.GAME, _new: GameManager.GAME) -> void:
	# GATE - old game must be hammer game:
	if old != GameManager.GAME.HAMMER:
		return
	
	cur_state = STATE.MOVE_GAME
	
	return


func _activate_game() -> void:
	GameManager.switch_game(GameManager.GAME.HAMMER)

# Gets batteryman to play the game:
func _play_game() -> void:
	# GATE - must have reference to game:
	if not game:
		game_ongoing = false
		return
	
	# Hit target:
	_play_anim("Swing")
	# NOTE: This animation calls _hit_target():


# This function is called by Batteryman's swing animation:
func _hit_target() -> void:
	game.batteryman_hit()
	_play_audio(SFX_HIT)


# Returns batteryman to idle pos after swing is done:
func _return_to_idle(anim: String) -> void:
	if  anim == "Swing":
		game_ongoing = false


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


# Moves Batteryman to a point:
func _go_to_point(delta:float, point: Vector3) -> bool:
	# Exit if close to destination:
	if (global_position - point).length() < 0.1:
		return true
	
	# Move and return:
	_update_direction(delta, point)
	_update_velocity()
	move_and_slide()
	
	return false


# Handles Batteryman's looking direction:
func _update_direction(delta: float, target: Vector3) -> void:
	# GATE - batteryman must be on floor to look around:
	if not is_on_floor():
		return
	
	# Calculate new basis:
	var pos = target - global_position
	var new_basis: Basis = Basis.looking_at(pos, Vector3.UP)
	
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
	
	return


# Update the velocity of batteryman:
func _update_velocity() -> void:
	# GATE - turtle must be on floor to move:
	if not is_on_floor():
		return
	
	# Velocity calculations:
	var step = speed
	
	# Update velocity:
	velocity = (-transform.basis.z * step)
	
	return


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


#===============================================================================
#	ANIMATIONS:
#===============================================================================
func _play_anim(anim: String, blend: float = 1, play_spd: float = 1.0) -> void:
	_anim_player.play(anim, blend, play_spd)
	#_anim_player.queue("Swimming")
