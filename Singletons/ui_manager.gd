#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# UI:
var ui: UserInterface = null


#===============================================================================
#	FUNCTIONS - UI:
#===============================================================================
# Updates the interact prompt:
func update_interact_prompt(msg: String = "", vis: bool = true) -> void:
	# GATE - ui reference must exist:
	if not ui:
		return
	
	ui.update_interact_prompt(msg, vis)


func set_ring_power(power: float) -> void:
	# GATE - ui reference must exist:
	if not ui:
		return
	
	ui.set_ring_power(power)


func set_ring_count(c: int, max_c: int) -> void:
	# GATE - ui reference must exist:
	if not ui:
		return
	
	ui.set_ring_count(c, max_c)


func set_timer(t: int) -> void:
	# GATE - ui reference must exist:
	if not ui:
		return
	
	ui.set_timer(t)


func set_guesses(g: int) -> void:
	# GATE - ui reference must exist:
	if not ui:
		return
	
	ui.set_guesses(g)
