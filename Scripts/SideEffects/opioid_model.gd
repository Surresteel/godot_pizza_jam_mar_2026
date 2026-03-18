#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name OpioidModel
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# INTERACTABLE:
@onready var interactable: Interactable = $Interactable


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Node Initialisation:
func _ready() -> void:
	interactable.activated.connect(_pick_up)


# Adds the opioid to the player inventory:
func _pick_up() -> void:
	PlayerInventory.add_item(Opioid.new())
	self.queue_free()
