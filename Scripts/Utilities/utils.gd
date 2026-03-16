#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Utils
extends RefCounted


#===============================================================================
#	FUNCTIONS SPATIAL:
#===============================================================================

# Returns the nearest node to a point, from a list of nodes.
static func get_nearest_node(point: Vector3, nodes: Array) -> Node3D:
	# GATE - node list must not be empty:
	if nodes.is_empty():
		return null
	
	# Initialise loop variables:
	var nearest_dist_sq: float = INF
	var nearest: Node3D = null
	
	# Find node nearest to point:
	for node in nodes:
		# GATE - node must exist:
		if not node:
			continue
		
		# ASSERT - Node must be of type Node3D:
		assert(node is Node3D, "Utils.get_nearest(): node is not Node3D")
		
		# Distance must be shorter:
		var dist_sq = (point - node.global_position).length_squared()
		if dist_sq < nearest_dist_sq:
			nearest_dist_sq = dist_sq
			nearest = node
	
	# Return nearest node:
	return nearest


# Returns whether two vector3s are approximately equal, ignoring y value:
static func vec3_equal_approx_2d(v1: Vector3, v2: Vector3) -> bool:
	v1.y = 0
	v2.y = 0
	return v1.is_equal_approx(v2)
