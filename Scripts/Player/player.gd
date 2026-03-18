#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends CharacterBody3D
class_name Player


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# INPUT:
@onready var camera: PlayerCamera = $"Camera Pivot/Camera3D"
@onready var interact: ShapeCast3D = $"Camera Pivot/InteractCast"

# MOVEMENT:
@onready var character: Node3D = $DrillBugJ
@export var speed := 3.0
@export var fall_speed := 1.0
@export var turn_rate: float = 8.0

# INVENTORY:
var inv := PlayerInventory


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Node initialisation:
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.game_change.connect(_on_game_change)


func _physics_process(delta: float) -> void:
	#InputHandling
	var input:Vector2 = Input.get_vector("leftward","rightward","forward",
			"backward")
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
	
	# Align player character:
	_align_character(delta)
	
	# Check for interactables:
	_check_interactables()
	
	move_and_slide()


# Input handling:
func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventKey and event.keycode == KEY_ESCAPE:
	#	get_tree().quit()
	
	if event.is_action_pressed("interact"):
		interact.force_update_transform()
		_interact()


#===============================================================================
#	FUNCTIONS - MOVEMENT:
#===============================================================================
# Aligns the player character to the velocity vector:
func _align_character(delta: float) -> void:
	# Get alignment ref:
	var align_vec: Vector3 = -velocity.normalized()
	if align_vec.is_zero_approx():
		align_vec = -character.transform.basis.z
		align_vec.y = 0
		align_vec = align_vec.normalized()
	
	# Get target basis:
	var up := Vector3.UP
	if absf(up.dot(align_vec)) > 0.99:
		up = Vector3.UP.rotated(character.global_basis.x, deg_to_rad(10))
	var new_basis := Basis.looking_at(align_vec, up)
	var current_quat = character.transform.basis.get_rotation_quaternion()
	var target_quat = new_basis.get_rotation_quaternion()
	var angle_diff = current_quat.angle_to(target_quat)
	
	# GATE - angular difference must not be approximately zero:
	if angle_diff < 0.001:
		return
	
	# Apply slerped basis:
	var weight = min(1.0, (turn_rate * delta) / angle_diff)
	character.transform.basis = Basis(current_quat.slerp(target_quat, weight))
	
	return


#===============================================================================
#	FUNCTIONS - LIFECYCLE:
#===============================================================================
# Handles node lifecycle as game state changes:
func _on_game_change(_old: GameManager.GAME, new: GameManager.GAME) -> void:
	if new == GameManager.GAME.NONE:
		print("none enabled")
		self.process_mode = Node.PROCESS_MODE_INHERIT
		self.visible = true
		camera.make_current()
	else:
		print("none disabled")
		self.process_mode = Node.PROCESS_MODE_DISABLED
		self.visible = false
		camera.clear_current()


#===============================================================================
#	FUNCTIONS - INTERACTABLE:
#===============================================================================
# Checks for nearby interactables, if they exist:
func _check_interactables() -> void:
	# GATE - must be colliding with something:
	if interact.get_collision_count() == 0:
		return
	
	#print("Can Interact!")
	
	return


# Interacts with a nearby interactable, if it exists:
func _interact() -> void:
	# GATE - must be colliding with something:
	if interact.get_collision_count() == 0:
		return
	
	# GATE - collision object must be interactable:
	var interactable: Object = interact.get_collider(0)
	if interactable is not Interactable:
		return
	
	# Activate interactable:
	interactable = interactable as Interactable
	interactable.activate()
	
	return
