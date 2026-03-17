extends CharacterBody3D
class_name DrillBug

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var steering_behaviour: SteeringBehaviour = $"Steering Behaviour"

@export var race_waypoints: Array[WayPoint]
var current_waypoint: int
var length: float = 0.3 #arbitary length used for distance to points and steering behaviours
@export var drillbugs: Array[DrillBug]

var racing: bool = false
var drilling: bool = false

var speed:= 0.5
var dig_speed:= 0.2
var aceleration:= 1.0
var max_speed: float = 0.5

@export var doped: bool = false

func start_drilling() -> void:
	animation_player.play("drillbug animation library/Drilling")
	drilling = true
	steering_behaviour.set_defaults(dig_speed,aceleration)
	max_speed = dig_speed

func stop_drilling() -> void:
	animation_player.queue("drillbug animation library/Run")
	drilling = false
	steering_behaviour.set_defaults(speed,aceleration)
	max_speed = speed

func start_race() -> void:
	if race_waypoints.is_empty():
		print("invalid waypoints")
		return
	current_waypoint = 0
	racing = true
	animation_player.play("drillbug animation library/Run")


func _ready() -> void:
	racing = true
	speed = randf_range(0.75,1.5)
	dig_speed = randf_range(0.5,1.75)
	aceleration = randf_range(1,3)
	max_speed = speed
	steering_behaviour.set_defaults(max_speed,max_speed*0.5)
	if doped:
		_dope_bug()

func _physics_process(delta: float) -> void:
	if !racing:
		return
	var new_velocity :Vector3 = Vector3.ZERO
	var min_speed: float = max_speed * 0.7
	
	#steering to stay aligned with a path
	new_velocity += steering_behaviour.follow_path(velocity, race_waypoints, length) * delta
	
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
		#rotate forward
		var angle = atan2(-velocity.x, -velocity.z)
		global_rotation.y =  angle


func _dope_bug() -> void:
	speed += 1
	dig_speed += 1
	aceleration += 1
	max_speed = speed
	steering_behaviour.set_defaults(max_speed,max_speed*0.5)
