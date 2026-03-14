extends Node3D
class_name SteeringBehaviour


@export var path_radius: float = 0.5
@export var desired_seperation: float = 0.25

var max_speed: float
var max_force: float

var steering_line = ImmediateMesh.new()
var velocity_line = ImmediateMesh.new()
var seperation_line = ImmediateMesh.new()
var path_line = ImmediateMesh.new()
var material := preload("uid://djflvx1tyl8nn")

var normalnew = MeshInstance3D.new()
var futuresphere = MeshInstance3D.new()
var sphere = SphereMesh.new()
var actualPath = ImmediateMesh.new()

var failsafe = false

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
func get_future_pos(velocity: Vector3, Length: float = 0.15) -> Vector3:
	return global_position + velocity.normalized() * Length

func get_normal_from_path(start_pos: Vector3, end_pos: Vector3, future_pos: Vector3) -> Vector3:
	var a: Vector3 = future_pos - start_pos
	var b: Vector3 = end_pos - start_pos
	b = b.normalized()
	b = b * (a.dot(b))
	return start_pos + b


func follow_path(current_velcoity: Vector3, start_pos: Vector3, end_pos: Vector3, length: float) -> Vector3:
	#
	#if failsafe:
		#return Vector3.ZERO
	
	var future_pos:= get_future_pos(current_velcoity)
	var normal_pos:= get_normal_from_path(start_pos,end_pos,future_pos)
	
	#debugging
	#actualPath.clear_surfaces()
	#material.albedo_color = Color.REBECCA_PURPLE
	#actualPath.surface_begin(Mesh.PRIMITIVE_LINES, material)
	#actualPath.surface_set_color(Color.REBECCA_PURPLE)
	#actualPath.surface_add_vertex(start_pos)
	#actualPath.surface_set_color(Color.REBECCA_PURPLE)
	#actualPath.surface_add_vertex(end_pos)
	#actualPath.surface_end()
	#
	#normalnew.mesh = sphere
	#normalnew.position = normal_pos
	#sphere.radius = 0.005
	#sphere.height = sphere.radius*2
	#
	#futuresphere.mesh = SphereMesh.new()
	#futuresphere.mesh.radius = 0.005
	#futuresphere.mesh.height = sphere.radius*2
	#futuresphere.position = future_pos
	#var mat1 := StandardMaterial3D.new()
	#futuresphere.mesh.material = mat1
	#mat1.albedo_color = Color.REBECCA_PURPLE
	#debugging end
	
	var distance = future_pos.distance_to(normal_pos)
	if distance > path_radius: #path radius, change if needed
		print(distance)
		var target_pos := (normal_pos + ((end_pos - start_pos).normalized() * length))
		
		var steer := target_pos - global_position# - current_velcoity
		steer.limit_length(max_force)
		_render_line(steer,path_line,Color.BLACK)
		failsafe = true
		return steer
	else:
		return Vector3.ZERO#get_steering_force(end_pos,current_velcoity)


## seperation
func seperate(drillbugs: Array[DrillBug], current_velcoity: Vector3) -> Vector3:
	
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
	create_line(steering_line)
	
	create_line(velocity_line)
	
	create_line(seperation_line)
	
	create_line(path_line)
	create_line(actualPath)
	get_tree().get_root().add_child.call_deferred(normalnew)
	get_tree().get_root().add_child.call_deferred(futuresphere)

func create_line(line):
	var mesh = MeshInstance3D.new()
	mesh.mesh = line
	mesh.cast_shadow = false
	get_tree().get_root().add_child.call_deferred(mesh)

func _render_line(target_pos: Vector3, line: ImmediateMesh, colour: Color) -> void:
	return
	line.clear_surfaces()
	material.albedo_color = colour
	
	line.surface_begin(Mesh.PRIMITIVE_LINES, material)
	line.surface_set_color(colour)
	line.surface_add_vertex(target_pos + global_position)
	line.surface_set_color(colour)
	line.surface_add_vertex(global_position)
	line.surface_end()
