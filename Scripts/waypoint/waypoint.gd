extends Node3D
class_name WayPoint

@export var Start_wayPoint: WayPoint = self
@export var next_waypoint: WayPoint

@export var path_radius: float = 0.2


func _on_mesh_instance_3d_editor_state_changed() -> void:
	print("weehaw")
