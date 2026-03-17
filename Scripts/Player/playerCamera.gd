extends Camera3D
class_name PlayerCamera

@export var pivot: Node3D
@export var sensitivity := 10.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var x_rotation: float = -event.screen_relative.y * sensitivity * \
				get_process_delta_time()
		var y_rotation: float = -event.screen_relative.x * sensitivity * \
				get_process_delta_time()
		
		pivot.rotation_degrees.x = clampf(pivot.rotation_degrees.x + x_rotation, 
				-90,90)
		pivot.rotation_degrees.y += y_rotation
