@tool
extends MeshInstance3D
class_name PathVisuliser

var path_mesh: MeshInstance3D = MeshInstance3D.new()
const PATH = preload("uid://cdltn10le1v0o")
@onready var pivot: Node3D = $Pivot

func _ready() -> void:
	if Engine.is_editor_hint():
		pivot.add_child(path_mesh)
	else:
		pivot.add_child(path_mesh)
		#if path_mesh != null:
			#path_mesh.queue_free()

func create_path_visual(path_radius: float, path_start: Vector3, path_end: Vector3) -> void:
	path_mesh.mesh = CapsuleMesh.new()
	var path_visual : CapsuleMesh = path_mesh.mesh
	path_visual.material = PATH
	path_visual.radius = path_radius
	path_visual.height = (path_end-path_start).length() + path_radius * 2
	pivot.global_position = (path_end-path_start).normalized() * ((path_end-path_start).length()/2) + path_start
	path_mesh.rotation_degrees.x = 90
	pivot.look_at(path_end)
