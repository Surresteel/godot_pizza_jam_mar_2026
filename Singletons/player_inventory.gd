#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# INVENTORY:
var inventory: Array[Item]



#===============================================================================
#	FUNCTIONS - INVENTORY:
#===============================================================================
# Adds an item to the player inventory:
func add_item(item: Item) -> void:
	# GATE - item must exist:
	if not item:
		return
	
	# Add item to array:
	inventory.append(item)


# Returns item of the given name, if it exists in the inventory:
func get_item_by_name(item_name: String) -> Item:
	var idx := inventory.find_custom(func(item: Item): \
			return item.item_name == item_name)
	
	# GATE - Item must be in inventory:
	if idx == -1:
		return null
	
	return inventory[idx]
