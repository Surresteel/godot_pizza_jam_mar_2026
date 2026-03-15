extends CharacterBody3D
class_name DrillBug

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var steering_behaviour: SteeringBehaviour = $"Steering Behaviour"

@export var race_waypoints: Array[Node3D]
var current_waypoint: int
var length: float = 0.3 #arbitary length used for distance to points and steering behaviours
@export var drillbugs: Array[DrillBug]

var racing: bool = false
var drilling: bool = false

@export var speed:= 0.5
@export var dig_speed:= 0.2
@export var aceleration:= 1.0
var max_speed: float = 0.5


func start_drilling() -> void:
	animation_player.play("drill placeholder")
	drilling = true
	steering_behaviour.set_defaults(dig_speed,aceleration)
	max_speed = dig_speed

func stop_drilling() -> void:
	var current_time := animation_player.current_animation_position
	animation_player.play_section("drill placeholder final",current_time)
	drilling = false
	steering_behaviour.set_defaults(speed,aceleration)
	max_speed = speed

func start_race() -> void:
	if race_waypoints.is_empty():
		print("invalid waypoints")
		return
	current_waypoint = 0
	racing = true


func _ready() -> void:
	start_race()
	speed = randf_range(0.75,2)
	dig_speed = randf_range(0.5,1.75)
	aceleration = randf_range(0.66,3)
	velocity.z = -0.001
	max_speed = speed
	steering_behaviour.set_defaults(max_speed,max_speed*0.5)

func _physics_process(delta: float) -> void:
	if !racing:
		return
	var new_velocity :Vector3 = Vector3.ZERO
	var min_speed: float = max_speed * 0.7
	
	#steering to stay aligned with an arbitary path
	var start_pos := race_waypoints[(current_waypoint-1+14)%14].global_position
	var end_pos := race_waypoints[current_waypoint].global_position
	
	
	new_velocity += steering_behaviour.follow_path(velocity, start_pos,end_pos,length) * delta
	
	#steering to avoid other drillbugs
	new_velocity += steering_behaviour.seperate(drillbugs,velocity) * delta
	
	
	velocity += new_velocity
	velocity = velocity.limit_length(max_speed)
	
	if velocity.length() < min_speed:
		velocity = velocity.normalized() * min_speed
	
	new_velocity = Vector3.ZERO
	
	move_and_slide()


func _process(_delta: float) -> void:
	if racing:
		var dir: Vector3 = (race_waypoints[current_waypoint].global_position - global_position)
		if dir.length() < 0.5:
			current_waypoint += 1
			current_waypoint %= 14
			return
		dir = dir.normalized()
		
		#rotate forward
		var angle = atan2(-velocity.x, -velocity.z)
		global_rotation.y =  angle
