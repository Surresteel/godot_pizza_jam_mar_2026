#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name RingStand
extends StaticBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# INTERACTABLE:
@onready var interactable: Interactable = $Interactable
@onready var tgt_base: Node3D = $Targets

# GAME
@export var player: RingTosserplayer = null
signal game_won()
@export var req_hits: int = 5
var ring_tally: int = 0


#===============================================================================
#	FUNCTIONS - CALLBACKS:
#===============================================================================
# Node initialisation:
func _ready() -> void:
	GameManager.game_change.connect(_on_game_change)
	interactable.activated.connect(_activate_game)
	var targets: Array = tgt_base.get_children()
	for target in targets:
		if target and target is RingTarget:
			target.ring_on.connect(_on_ring_on)
			target.ring_off.connect(_on_ring_off)


# Activates the game:
func _activate_game() -> void:
	GameManager.switch_game(GameManager.GAME.RING)


# Handles node lifecycle as game state changes:
func _on_game_change(old: GameManager.GAME, new: GameManager.GAME) -> void:
	if new == GameManager.GAME.RING:
		interactable.toggle(false)
	elif old == GameManager.GAME.RING:
		if not player.has_won:
			interactable.toggle(true)
	return



func _on_ring_on() -> void:
	ring_tally += 1
	
	if ring_tally == req_hits:
		game_won.emit()
	
	return


func _on_ring_off() -> void:
	ring_tally -= 1


#===============================================================================
#	EOF:
#===============================================================================
