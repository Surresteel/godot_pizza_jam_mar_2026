extends Node3D
class_name SteeringBehaviour

@export var max_speed: float
@export var max_force: float
var steering_line = ImmediateMesh.new()
var velocity_line = ImmediateMesh.new()
var seperation_line = ImmediateMesh.new()
var path_line = ImmediateMesh.new()
var material := preload("uid://djflvx1tyl8nn")

func set_defaults(speed, force) -> void:
	max_speed = speed
	max_force = force


## Steering Force
func get_steering_force(target: Vector3, current_velocity: Vector3) -> Vector3:
	var steering_force: Vector3 = (_get_desired_velocity(target) - current_velocity).limit_length(max_force)
	_render_line(steering_force,steering_line,Color.BLUE)
	_render_line(current_velocity,velocity_line,Color.GREEN)
	return steering_force

func _get_desired_velocity(target: Vector3) -> Vector3:
	return (target - global_position).normalized() * max_speed


## Path Following
func get_future_pos(velocity: Vector3, Length: float = 0.3) -> Vector3:
	return global_position + velocity.normalized() * Length

func get_normal_from_path(start_pos: Vector3, end_pos: Vector3, future_pos: Vector3) -> Vector3:
	var a: Vector3 = future_pos - start_pos
	var b: Vector3 = end_pos - start_pos
	var theta = a.angle_to(b)
	
	var d: float = a.length() * cos(theta)
	b = b.normalized() * d
	return start_pos + b


func follow_path(current_velcoity: Vector3, start_pos: Vector3, end_pos: Vector3, length: float) -> Vector3:
	
	var future_pos:= get_future_pos(current_velcoity)
	var normal_pos:= get_normal_from_path(start_pos,end_pos,future_pos)
	
	
	var distance = future_pos.distance_to(normal_pos)
	if distance > 1: #path radius, change if needed
		var target_pos := (end_pos - start_pos).normalized() * length
		
		var steer := target_pos - current_velcoity
		steer.limit_length(max_force)
		_render_line(steer,path_line,Color.BLACK)
		return steer
	else:
		path_line.clear_surfaces()
		return Vector3.ZERO


## seperation
func seperate(drillbugs: Array[DrillBug], current_velcoity: Vector3) -> Vector3:
	var desired_seperation := 0.15
	
	var amount: int = 0
	var sum: Vector3 = Vector3.ZERO
	
	for bug in drillbugs:
		var d = global_position.distance_to(bug.global_position)
		if bug != self and d < desired_seperation:
			var difference = global_position - bug.global_position
			difference = difference.normalized()
			sum += difference
			amount += 1
	
	if amount > 0:
		sum /= amount
		sum = sum.normalized() * max_speed
		var steer := sum - current_velcoity
		steer = Vector3(steer.x,0,steer.z)
		steer.limit_length(max_force)
		_render_line(steer,seperation_line,Color.RED)
		return steer
	seperation_line.clear_surfaces()
	return Vector3.ZERO


## Debuging
func _ready() -> void:
	var steer_mesh = MeshInstance3D.new()
	steer_mesh.mesh = steering_line
	steer_mesh.cast_shadow = false
	get_tree().get_root().add_child.call_deferred(steer_mesh)
	
	var velo_mesh = MeshInstance3D.new()
	velo_mesh.mesh = velocity_line
	velo_mesh.cast_shadow = false
	get_tree().get_root().add_child.call_deferred(velo_mesh)
	
	var sepe_mesh = MeshInstance3D.new()
	sepe_mesh.mesh = seperation_line
	sepe_mesh.cast_shadow = false
	get_tree().get_root().add_child.call_deferred(sepe_mesh)
	
	var path_mesh = MeshInstance3D.new()
	path_mesh.mesh = path_line
	path_mesh.cast_shadow = false
	get_tree().get_root().add_child.call_deferred(path_mesh)

func _render_line(target_pos: Vector3, line: ImmediateMesh, colour: Color) -> void:
	line.clear_surfaces()
	material.albedo_color = colour
	
	line.surface_begin(Mesh.PRIMITIVE_LINES, material)
	line.surface_set_color(colour)
	line.surface_add_vertex(target_pos + global_position)
	line.surface_set_color(colour)
	line.surface_add_vertex(global_position)
	line.surface_end()
