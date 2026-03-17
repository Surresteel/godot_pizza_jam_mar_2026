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
enum GAME{NONE, TURTLE, HAMMER, RING, DRILL}
signal game_change(old: GAME, new: GAME)
var current_game := GAME.NONE


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


#===============================================================================
#	FUNCTIONS STATE:
#===============================================================================
# Switches to a different game:
func switch_game(new_game: GAME):
	# GATE - new game must be different from current:
	if new_game == current_game:
		return
	
	# Handle exit game code:
	#match current_game:
	#	GAME.NONE:
	#		player.process_mode = Node.PROCESS_MODE_DISABLED
	#	GAME.TURTLE:
	#		pass
	#	GAME.HAMMER:
	#		pass
	#	GAME.RING:
	#		pass
	#	GAME.DRILL:
	#		pass
	
	# Handle enter game code:
	#match new_game:
	#	GAME.NONE:
	#		player.process_mode = Node.PROCESS_MODE_INHERIT
	#		player.camera.make_current()
	#	GAME.TURTLE:
	#		pass
	#	GAME.HAMMER:
	#		pass
	#	GAME.RING:
	#		pass
	#	GAME.DRILL:
	#		pass
	
	# Update game:
	print("changing state")
	game_change.emit(current_game, new_game)
	current_game = new_game
	return
