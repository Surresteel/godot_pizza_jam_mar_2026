#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Pinhead
extends CharacterBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# SIGNALS:
signal ring_on()
#signal ring_off()


# ANIMATION:
@onready var _anim_player: AnimationPlayer = \
		$SP0RingTossAnimations/AnimationPlayer


# RING DETECTION:
@onready var killzoneFwd: Area3D = \
		$SP0RingTossAnimations/Armature/Skeleton3D/BoneAttachment3D/KillzoneFwd
@onready var killzoneAft: Area3D = \
		$SP0RingTossAnimations/Armature/Skeleton3D/BoneAttachment3D/KillzoneAft
var contact_fwd: Node3D = null
var contact_aft: Node3D = null
var hit: bool = false


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Node initialisation:
func _ready() -> void:
	# Connect collision signals:
	killzoneFwd.body_entered.connect(func(node): contact_fwd = node)
	killzoneFwd.body_exited.connect(func(_node): contact_fwd = null)
	killzoneAft.body_entered.connect(func(node): contact_aft = node)
	killzoneAft.body_exited.connect(func(_node): contact_aft = null)
	_play_anim("Idle")


# Node behaviour:
func _process(_delta: float) -> void:
	if contact_fwd and contact_aft and contact_fwd == contact_aft:
		if not hit:
			hit = true
			ring_on.emit()
			_play_anim("RingHit")
			return
		else:
			return


#===============================================================================
#	ANIMATIONS:
#===============================================================================
func _play_anim(anim: String, blend: float = 1, play_spd: float = 1.0) -> void:
	_anim_player.play(anim, blend, play_spd)
	#_anim_player.queue("Idle")
