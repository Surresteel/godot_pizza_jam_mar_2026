#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# PLAYER:
var player: Player = null

# GAME STATE:
enum GAME{NONE, TURTLE, HAMMER, COPYCAT, RING, DRILL}
signal game_change(old: GAME, new: GAME)
var current_game := -1


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


#===============================================================================
#	FUNCTIONS - STATE:
#===============================================================================
# Switches to a different game:
func switch_game(new_game: GAME):
	# GATE - new game must be different from current:
	if new_game == current_game:
		return
	
	# Update game:
	print("changing state")
	game_change.emit(current_game, new_game)
	current_game = new_game
	return
