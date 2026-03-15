@tool
extends MeshInstance3D

var path_mesh: MeshInstance3D = MeshInstance3D.new()

func _ready() -> void:
	pass
	add_child(path_mesh)
	create_path_visual()

func create_path_visual() -> void:
	pass
	path_mesh.mesh = CapsuleMesh.new()
