#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name BandStage
extends StaticBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# INTERACTABLE:
@onready var interactable: Interactable = $Interactable

# Audio Stream Player:
@onready var audio_player: AudioStreamPlayer3D = $AudioStream

# Music:
var _songs: Array[AudioStream] = [
	preload("uid://cjnoec8qnfyvq"),
	preload("uid://d4l3wamhtocge"),
	preload("uid://dltxyko14c1kl")
]
var _cur_song: int = 0


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Initialise Node:
func _ready() -> void:
	audio_player.finished.connect(_next_song)
	interactable.activated.connect(_next_song)
	_play_audio(_songs[_cur_song])


#===============================================================================
#	FUNCTIONS - AUDIO:
#===============================================================================
# Cycles to the next song:
func _next_song() -> void:
	_cur_song = (_cur_song + 1) % _songs.size()
	_play_audio(_songs[_cur_song])


# Plays an audio resource from the turtle:
func _play_audio(resource: AudioStream, override: bool = true) -> void:
	# GATE - must not be playing if override disabled:
	if not override and audio_player.playing:
		return
	
	# Play audio:
	audio_player.stream = resource
	audio_player.play()
	
	return


#===============================================================================
#	EOF:
#===============================================================================
