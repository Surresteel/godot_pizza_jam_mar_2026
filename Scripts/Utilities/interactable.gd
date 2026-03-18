#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Interactable
extends Area3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# IDENTITY:
@export var owner_node: Node3D = null
signal activated()
@export var message: String = "Interact"

# Collider:
@onready var collider: CollisionShape3D = $Collider
@export var radius: float = 2.0


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Node Initialisation:
func _ready() -> void:
	# Update sphere radius:
	var sphere := collider.shape as SphereShape3D
	if sphere:
		sphere.radius = radius


#===============================================================================
#	FUNCTIONS - INTERACTABLE:
#===============================================================================
# Activates the interactable:
func activate() -> void:
	activated.emit()
