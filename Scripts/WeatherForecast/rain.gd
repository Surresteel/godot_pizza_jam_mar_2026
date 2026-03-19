#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Rain
extends GPUParticles3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# PLAYER:
var cur_cam: Camera3D = null


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	cur_cam = get_viewport().get_camera_3d()
	GameManager.game_change.connect(_get_active_cam)


func _process(_delta: float) -> void:
	if not cur_cam:
		cur_cam = get_viewport().get_camera_3d()
		if not cur_cam:
			global_position = Vector3.ZERO
			return
	
	global_position = cur_cam.global_position


#===============================================================================
#	FUNCTIONS - MOVEMENT:
#===============================================================================
# Gets the active camera after a game switch:
func _get_active_cam(_old: GameManager.GAME, _new: GameManager.GAME) -> void:
	#await get_tree().create_timer(2).timeout
	cur_cam = get_viewport().get_camera_3d()
