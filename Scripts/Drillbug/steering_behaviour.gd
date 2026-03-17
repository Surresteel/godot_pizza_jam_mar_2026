extends Node3D
class_name SteeringBehaviour


@export var draw_lines: bool = false

@export var desired_seperation: float = 0.2

var max_speed: float
var max_force: float

var steering_line = ImmediateMesh.new()
var velocity_line = ImmediateMesh.new()
var seperation_line = ImmediateMesh.new()
var path_line = ImmediateMesh.new()
var futurenormal_line = ImmediateMesh.new()
var material := preload("uid://djflvx1tyl8nn")

var normalnew = MeshInstance3D.new()
var futuresphere = MeshInstance3D.new()
var sphere = SphereMesh.new()
var actualPath = ImmediateMesh.new()

func set_defaults(speed, force) -> void:
	max_speed = speed
	max_force = force


## Steering Force
func get_steering_force(target: Vector3, current_velocity: Vector3) -> Vector3:
	var steering_force: Vector3 = (_get_desired_velocity(target) - current_velocity).limit_length(max_force)
	#_render_line(steering_force,steering_line,Color.BLUE)
	#_render_line(current_velocity,velocity_line,Color.GREEN)
	return steering_force

func _get_desired_velocity(target: Vector3) -> Vector3:
	return (target - global_position).normalized() * max_speed


## Path Following
func get_future_pos(velocity: Vector3, Length: float = 0.15) -> Vector3:
	return global_position + velocity.normalized() * Length

func get_normal_from_path(start_pos: Vector3, end_pos: Vector3, future_pos: Vector3) -> Vector3:
	var a: Vector3 = future_pos - start_pos
	var b: Vector3 = end_pos - start_pos
	var normal := b.normalized()
	normal *= (a.dot(normal))
	
	var anormal := start_pos.distance_to(normal + start_pos)
	var bnormal := (normal + start_pos).distance_to(end_pos)
	
	if anormal + bnormal > start_pos.distance_to(end_pos) * 1.05:
		normal = end_pos - start_pos
	
	return start_pos + normal


func follow_path(current_velcoity: Vector3, path: Array[WayPoint], length: float) -> Vector3:
	
	var closest_point_distance: float = 69420.0
	var target_pos: Vector3
	var normal_pos: Vector3
	var future_pos:= get_future_pos(current_velcoity)
	
	var start_pos: Vector3
	var end_pos: Vector3
	
	var closest_point: WayPoint
	
	for points in path:
		
		start_pos = points.Start_wayPoint.global_position
		end_pos = points.next_waypoint.global_position
		
		normal_pos = get_normal_from_path(start_pos,end_pos,future_pos)
		
		var distance: float = future_pos.distance_to(normal_pos)
		
		if distance < closest_point_distance:
			closest_point = points
			closest_point_distance = distance
			target_pos = (normal_pos + ((end_pos - start_pos).normalized() * length))
	
	var wrong_way: bool = false
	if -global_basis.z.dot((closest_point.next_waypoint.global_position 
			- closest_point.Start_wayPoint.global_position).normalized()) < 0:
				wrong_way = false
	
	
	
	if closest_point_distance > closest_point.path_radius:
		var steer := get_steering_force(target_pos,current_velcoity)
		#scale the force by how far off the path they are
		steer = steer * (10 * (1 - closest_point.path_radius/closest_point_distance))
		_render_line(steer,path_line,Color.RED)
		_render_line(target_pos - global_position,futurenormal_line,Color.BLUE)
		_render_line(current_velcoity,velocity_line,Color.GREEN)
		return steer
	else:
		path_line.clear_surfaces()
		futurenormal_line.clear_surfaces()
		_render_line(current_velcoity,velocity_line,Color.GREEN)
		
		return get_steering_force(closest_point.next_waypoint.global_position,current_velcoity) 


## seperation
func seperate(drillbugs: Array[DrillBug], current_velcoity: Vector3) -> Vector3:
	
	var amount: int = 0
	var sum: Vector3 = Vector3.ZERO
	
	var closest_bug: float = desired_seperation
	
	for bug in drillbugs:
		var d = global_position.distance_to(bug.global_position)
		if bug != self and d < desired_seperation:
			var difference = global_position - bug.global_position
			difference = difference * (1-closest_bug/desired_seperation)
			sum += difference
			amount += 1
			
			if d < closest_bug:
				closest_bug = d
	
	if amount > 0:
		sum /= amount
		var steer := sum - current_velcoity
		steer = Vector3(steer.x,0,steer.z)
		steer = steer.limit_length(max_force*0.5)
		#_render_line(steer,seperation_line,Color.RED)
		return steer
	return Vector3.ZERO


## Debuging
func _ready() -> void:
	create_line(steering_line)
	
	create_line(velocity_line)
	
	create_line(seperation_line)
	
	create_line(path_line)
	create_line(actualPath)
	create_line(futurenormal_line)
	get_tree().get_root().add_child.call_deferred(normalnew)
	get_tree().get_root().add_child.call_deferred(futuresphere)

func create_line(line):
	var mesh = MeshInstance3D.new()
	mesh.mesh = line
	mesh.cast_shadow = false
	get_tree().get_root().add_child.call_deferred(mesh)

func _render_line(target_pos: Vector3, line: ImmediateMesh, colour: Color) -> void:
	if !draw_lines:
		return
	line.clear_surfaces()
	material.albedo_color = colour
	
	line.surface_begin(Mesh.PRIMITIVE_LINES, material)
	line.surface_set_color(colour)
	line.surface_add_vertex(target_pos + global_position)
	line.surface_set_color(colour)
	line.surface_add_vertex(global_position)
	line.surface_end()
