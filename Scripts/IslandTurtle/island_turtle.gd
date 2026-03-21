#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name IslandTurtle
extends StaticBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# INTERACTABLE:
@onready var interactable: Interactable = $Interactable

# CAMERA:
@onready var cam: Camera3D = $Cam

# GAMEPLAY:
@onready var island_area: Area3D = $IslandZone
@export var turtles: Array[Turtle] = []
var _start_positions: Array[Transform3D]
var turtles_remaining: int = 0
var game_won: bool = false
var player_won: bool = false


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Node initialisation:
func _ready() -> void:
	# Connect signals:
	GameManager.game_change.connect(_on_game_change)
	island_area.body_exited.connect(_on_body_exit)
	interactable.activated.connect(_activate_game)
	
	# Get start positions of each turtle:
	for turtle in turtles:
		_start_positions.append(turtle.transform)
	
	# Initialise game:
	_end_game()


#===============================================================================
#	FUNCTIONS - GAMEPLAY:
#===============================================================================
# Activates the game state change:
func _activate_game() -> void:
	GameManager.switch_game(GameManager.GAME.TURTLE)


# Manages game state changes:
func _on_game_change(old: GameManager.GAME, new: GameManager.GAME) -> void:
	if new == GameManager.GAME.TURTLE:
		cam.make_current()
		interactable.toggle(false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_start_game()
	elif old == GameManager.GAME.TURTLE:
		cam.clear_current()
		interactable.toggle(true)
		_end_game()


# Sets up the game:
func _start_game() -> void:
	# ASSERT - start positions must match No. of turtles.
	assert(turtles.size() == _start_positions.size())
	
	# Move turtles to start position:
	for i in range(turtles.size()):
		turtles[i].transform = _start_positions[i]
	
	# Initialise states:
	turtles_remaining = turtles.size()
	game_won = false
	player_won = false
	
	# Enable Turtles:
	for turtle in turtles:
		if turtle:
			turtle.add_to_group("turtles")
			turtle.visible = true
			turtle.process_mode = Node.PROCESS_MODE_INHERIT


# Ends the game:
func _end_game() -> void:
	# Disable Turtles:
	for turtle in turtles:
		if turtle:
			turtle.visible = false
			turtle.process_mode = Node.PROCESS_MODE_DISABLED


# Monitors the game state:
func _check_game_state() -> void:
	if turtles_remaining == 1:
		for turtle in turtles:
			if turtle.is_dead:
				continue
			turtle.won()
			game_won = true
			if turtle is TurtlePlayer:
				player_won = true
			_victory_cycle()


# Handles the victory cycle at the end of the game:
func _victory_cycle() -> void:
	await get_tree().create_timer(6).timeout
	
	# TODO: GIVE PLAYER THE MAP SEGMENT:
	
	GameManager.switch_game(GameManager.GAME.NONE)


#===============================================================================
#	FUNCTIONS COLLISION:
#===============================================================================
# Handles turtles that exit the gameplay zone:
func _on_body_exit(node: Node3D) -> void:
	# GATE - other node must be a turtle:
	if node is not Turtle:
		return
	var turtle := node as Turtle
	
	# Remove turtle from game:
	turtle.kill()
	turtles_remaining -= 1
	_check_game_state()
