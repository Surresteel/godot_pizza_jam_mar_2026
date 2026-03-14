extends CharacterBody3D
class_name Player

@onready var camera: PlayerCamera = $"Camera Pivot/Camera3D"

@export var speed := 3.0
@export var fall_speed := 1.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	#InputHandling
	var input:Vector2 = Input.get_vector("leftward","rightward","forward","backward")
	var direction = camera.global_basis * Vector3(input.x,0,input.y)
	direction = Vector3(direction.x,0,direction.z).normalized() * speed
	velocity.x = direction.x
	velocity.z = direction.z
	
	#floor and gravity
	if not is_on_floor():
		if velocity.y < 0:
			fall_speed += delta * 3
		velocity.y += get_gravity().y * delta * fall_speed
	else:
		velocity.y = 0
		fall_speed = 1
		if Input.is_action_just_pressed("squidward"):
			velocity.y += 2.0
	
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		get_tree().quit()
