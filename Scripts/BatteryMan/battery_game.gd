#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name BatteryGame
extends StaticBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================

# AUDIO:
#const SFX_HIT: AudioStreamWAV = TBD
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer


# COLLISIONS:
@onready var area: Area3D = $Target
@onready var bar: Node3D = $Bar


#===============================================================================
#	CALLBACKS:
#===============================================================================

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	pass


#===============================================================================
#	FUNCTIONS COLLISION:
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
	var vel_avg: Vector3 = hammer.get_velocity_average()
	var dot_down: float = vel_avg.dot(Vector3.DOWN)
	var strength: float = clampf(dot_down / hammer.speed, 0.0, 1.0)
	
	# Set bar scale:
	_animate_bar(strength)
	
	return


#===============================================================================
#	FUNCTIONS - ANIMATIONS:
#===============================================================================

# Animates the bar according to strength:
func _animate_bar(strength: float, duration: float = 1.5):
	# Reset scale:
	bar.scale = Vector3(1, 0, 1)
	
	# Create grow tween:
	var tween = create_tween()
	tween.tween_property(bar, "scale", Vector3(1, strength, 1), duration)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	
	# Create shrink tween:
	tween.tween_property(bar, "scale", Vector3(1, 0, 1), duration)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN)


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
