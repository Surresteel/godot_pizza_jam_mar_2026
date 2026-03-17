@tool
extends Node3D
class_name WayPoint

@export var Start_wayPoint: WayPoint = self
@export var next_waypoint: WayPoint
@export var previous_waypoint: WayPoint

@export var path_radius: float = 0.2
@onready var path_visuliser: PathVisuliser = $MeshInstance3D

signal updated

@export_tool_button("Recreate","TerrainPath") var recreate = _create_new_path_visual

func _ready() -> void:
	if Engine.is_editor_hint():
		Start_wayPoint.set_notify_transform(true)
		if next_waypoint != null:
			next_waypoint.previous_waypoint = self
			updated.connect(previous_waypoint._create_new_path_visual)
		_create_new_path_visual()
	else:
		#Start_wayPoint.set_notify_transform(false)
		_create_new_path_visual()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		_create_new_path_visual()
		updated.emit()


func _create_new_path_visual() -> void:
	if !updated.has_connections():
		if next_waypoint != null:
			next_waypoint.previous_waypoint = self
			updated.connect(previous_waypoint._create_new_path_visual)
	
	if Start_wayPoint != null and next_waypoint != null:
		path_visuliser.create_path_visual(path_radius,Start_wayPoint.global_position, next_waypoint.global_position)
	else:
		path_visuliser.path_mesh.mesh = null
		print("not enough info")
