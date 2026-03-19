#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name CCPen
extends StaticBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# ANIMAL TYPES:
var animal_scene: PackedScene = preload("uid://cr75yplaeq4ei")

# INTERACTABLE:
@onready var interactable: Interactable = $Interactable

# CAMERA:
@onready var cam: Camera3D = $Cam
var margin: int = 10
var pan_rate: float = 1.0

# GAME:
@onready var spawn: Node3D = $Spawn
@onready var cage_spawn: Node3D = $CCCage/Spawn
@export var no_of_animals: int = 10
@export var max_guesses: int = 3
@export var max_time: int = 30000
var cur_guess = 0
var start_time: int = 0
var cur_time: int = 0
var _is_active: bool = false
var _animals: Array[CCAnimal]
var _original: CCAnimal = null


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	GameManager.game_change.connect(_on_game_change)
	interactable.activated.connect(_activate_game)
	_disable_node()


func _process(delta: float) -> void:
	if not _is_active:
		return
	
	# Count down:
	var now: int = Time.get_ticks_msec()
	cur_time = now - start_time
	if cur_time > max_time:
		GameManager.switch_game(GameManager.GAME.NONE)
	@warning_ignore("integer_division")
	UiManager.set_timer((max_time - cur_time) / 1000)
	
	var pan_dir = _get_pan_dir()
	if pan_dir != 0:
		_pan_cam(delta, pan_dir)


# Activates the game:
func _activate_game() -> void:
	GameManager.switch_game(GameManager.GAME.COPYCAT)
	
	return


#===============================================================================
#	INTPUT:
#===============================================================================
# Handles input:
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		GameManager.switch_game(GameManager.GAME.NONE)
	
	if event.is_action_pressed("hit"):
		# Get ray start and end:
		var mouse_pos := get_viewport().get_mouse_position()
		var ray_origin := cam.project_ray_origin(mouse_pos)
		var ray_end := ray_origin + cam.project_ray_normal(mouse_pos) * 100.0
		
		# Perform raycast:
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		query.collision_mask = 8
		var space_state = get_world_3d().direct_space_state
		var result : Dictionary = space_state.intersect_ray(query)
		
		# GATE -Ray must hit something:
		if result.is_empty():
			return
		
		# GATE - object must be CCAnimal:
		var obj: Node3D = result.collider
		if obj is not CCAnimal:
			return
		obj = obj as CCAnimal
		
		if obj.is_copycat:
			obj.explode()
			_win_game()
		else:
			cur_guess += 1
			UiManager.set_guesses(max_guesses - cur_guess)
		
		if cur_guess == max_guesses:
			_lose_game()
		
		return


#===============================================================================
#	FUNCTIONS - GAME:
#===============================================================================
func _win_game() -> void:
	await get_tree().create_timer(2).timeout
	GameManager.switch_game(GameManager.GAME.NONE)


func _lose_game() -> void:
	GameManager.switch_game(GameManager.GAME.NONE)


#===============================================================================
#	FUNCTIONS - CAMERA:
#===============================================================================
# Pans the camera:
func _pan_cam(delta: float, dir: int) -> void:
	# GATE - camera must exist:
	if not cam:
		return
	
	cam.rotate(Vector3.UP, pan_rate * dir * delta)
	return


#===============================================================================
#	FUNCTIONS - LIFECYCLE:
#===============================================================================
# Handles node lifecycle as game state changes:
func _on_game_change(old: GameManager.GAME, new: GameManager.GAME) -> void:
	if new == GameManager.GAME.COPYCAT:
		_enable_node()
	elif old == GameManager.GAME.COPYCAT:
		_disable_node()
	
	return


# Enables the game:
func _enable_node() -> void:
	_is_active = true
	_setup_game()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	interactable.monitorable = false
	cam.make_current()


# Disables the game:
func _disable_node() -> void:
	_is_active = false
	_clean_up_game()
	interactable.monitorable = true
	cam.clear_current()


# Sets up the game:
func _setup_game() -> void:
	# ASSERT - must be at least one animal:
	assert(no_of_animals > 0, "Must be at least one animal.")
	
	# Spawn target:
	_original = animal_scene.instantiate()
	get_tree().current_scene.add_child(_original)
	_original.global_position = cage_spawn.global_position
	_original.global_basis = cage_spawn.global_basis
	_original.is_original = true
	_original.randomise_traits()
	
	# Reset counters:
	start_time = Time.get_ticks_msec()
	cur_guess = 0
	cur_time = 0
	UiManager.set_guesses(max_guesses)
	
	# Spawn others:
	var cc_idx: int = randi_range(0, no_of_animals - 1)
	for i in range(no_of_animals):
		if not _is_active:
			return
		
		var offset := Vector3(randf()*2-1, 0, randf()*2-1)
		var animal = animal_scene.instantiate()
		get_tree().current_scene.add_child(animal)
		animal.global_position = spawn.global_position + offset
		if i == cc_idx:
			animal.copy_traits(_original)
		else:
			animal.randomise_traits()
		_animals.append(animal)
		await get_tree().create_timer(0.1).timeout


# Cleans up the game:
func _clean_up_game() -> void:
	# Delete original animal:
	if _original:
		_original.queue_free()
		_original = null
	
	# Delete animals:
	for animal in _animals:
		if animal:
			animal.queue_free()
	
	# Clear animal array:
	_animals.clear()


#===============================================================================
#	FUNCTIONS - HELPER:
#===============================================================================
# Returns the camera pan direction based on the mouse position:
func _get_pan_dir() -> int:
	var vp: Viewport = get_viewport()
	var mouse_pos = vp.get_mouse_position()
	var v_size = vp.get_visible_rect().size
	
	# Return direction if mouse is at either screen edge:
	if mouse_pos.x < margin:
		return 1
	if mouse_pos.x > v_size.x - margin:
		return -1
	
	# Return zero otherwise:
	return 0
