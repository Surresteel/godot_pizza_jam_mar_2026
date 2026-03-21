#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name BatteryGame
extends StaticBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# ANIMATION:
@onready var _anim_player: AnimationPlayer = \
		$StrengthTesterAnimations/AnimationPlayer

# AUDIO:
#const SFX_HIT: AudioStreamWAV = TBD
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer


# COLLISIONS:
@onready var area: Area3D = $Target
@onready var bar: Node3D = $Bar
var _is_animating: bool = false

# GAME:
@onready var puck: Node3D = $StrengthTesterAnimations/Puck
signal game_won(player_won: bool)
const PUCK_MIN_Y: float = 0.624
const PUCK_MAX_Y: float = 3.285
const PUCK_DIST: float = PUCK_MAX_Y - PUCK_MIN_Y
var last_player_hit: float = 0
var has_player_won: bool = false


#===============================================================================
#	CALLBACKS:
#===============================================================================

func _ready() -> void:
	bar.scale = Vector3(1, 0, 1)
	area.body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	pass


#===============================================================================
#	FUNCTIONS - GAMEPLAY:
#===============================================================================

# Processes collisions with other turtles:
func _on_body_entered(node: Node3D) -> void:
	# GATE - detected node must not be self:
	if node == self:
		return
	
	# GATE - other node must be a BatteryHammer:
	if node is not BatteryHammer:
		return
	var hammer := node as BatteryHammer
	
	# Get speed of strike:
	var vel_highest: Vector3 = hammer.get_velocity_highest()
	var dot_down: float = vel_highest.dot(Vector3.DOWN)
	var strength: float = clampf(dot_down / hammer.speed, 0.0, 2.0)
	strength *= hammer.weight_multi
	
	# Set bar scale:
	_animate_bar(strength, 1.5, true)
	
	return


# Called when batteryman hits the target:
func batteryman_hit() -> void:
	var strength: float = randf_range(1.0, 1.1)
	_animate_bar(strength)


#===============================================================================
#	FUNCTIONS - ANIMATIONS:
#===============================================================================
func _play_anim(anim: String, blend: float = 1, play_spd: float = 1.0) -> void:
	_anim_player.play(anim, blend, play_spd)


# Animates the bar according to strength:
func _animate_bar(power: float, duration: float = 1.5, is_player: bool = false):
	if is_player:
		last_player_hit = power
	elif power < last_player_hit:
		has_player_won = true
		game_won.emit(true)
	else:
		game_won.emit(false)
	
	# GATE - must not be animating:
	if _is_animating:
		return
	
	# Toggle _is_animating:
	_is_animating = true
	_play_anim("Bell Hit destroy")
	
	# Create grow tween:
	var tween = create_tween()
	tween.tween_property(bar, "scale", Vector3(1, power, 1), duration/2)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	var pos := PUCK_MIN_Y + PUCK_DIST * power
	tween.parallel().tween_property(puck, "global_position:y", pos, duration/2)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	
	# Create shrink tween:
	tween.tween_property(bar, "scale", Vector3(1, 0, 1), duration)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN)
	pos = PUCK_MIN_Y
	tween.parallel().tween_property(puck, "global_position:y", pos, duration)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN)
	
	# Connect reset:
	tween.finished.connect(func(): _is_animating = false)


#===============================================================================
#	FUNCTIONS AUDIO:
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
