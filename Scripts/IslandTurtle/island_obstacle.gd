#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name IslandObstacle
extends StaticBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================

# AUDIO:
const SFX_SHAKE: AudioStreamWAV = preload("uid://yxxr526gjpht")
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer


# COLLISION:
@onready var area: Area3D = $Area
@export var rest_coef: float = 0.9


#===============================================================================
#	CALLBACKS:
#===============================================================================

# Initialise node:
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)


#===============================================================================
#	FUNCTIONS COLLISION:
#===============================================================================

# Processes collisions with turtles:
func _on_body_entered(other_node: Node3D) -> void:
	# GATE - other node must be a turtle:
	if other_node is not Turtle:
		return
	var other_turtle := other_node as Turtle
	
	# Get collision normal and velocity:
	var normal = (other_turtle.global_position - global_position)
	normal.y = 0
	normal = normal.normalized()
	var relative_velocity = other_turtle.velocity
	var collision_speed = maxf(relative_velocity.dot(normal), 0.5)
	
	# Calculate impulse:
	var impulse_magnitude = (1 + rest_coef) * collision_speed
	impulse_magnitude /= 1 / other_turtle.mass
	
	# Apply force:
	var impulse_vector = impulse_magnitude * normal * 2.0
	other_turtle.pending_collision = impulse_vector / other_turtle.mass
	
	# Play audio:
	_play_audio(SFX_SHAKE)
	
	return


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
