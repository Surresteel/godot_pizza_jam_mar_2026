#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name IslandTurtle
extends StaticBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================

# GAMEPLAY:
@onready var island_area: Area3D = $IslandZone
@export var turtles: Array[Node3D] = []


#===============================================================================
#	CALLBACKS:
#===============================================================================

# Node initialisation:
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	island_area.body_exited.connect(_on_body_exit)


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
	turtle.remove_from_group("turtles")
	turtles.erase(turtle)
	turtle.queue_free()
