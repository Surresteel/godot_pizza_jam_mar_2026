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
signal ring_off()


# RING DETECTION:
@onready var killzoneFwd: Area3D = \
		$SP0RingTossUnfinished/Armature/Skeleton3D/BoneAttachment3D/KillzoneFwd
@onready var killzoneAft: Area3D = \
		$SP0RingTossUnfinished/Armature/Skeleton3D/BoneAttachment3D/KillzoneAft
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


# Node behaviour:
func _process(_delta: float) -> void:
	if contact_fwd and contact_aft and contact_fwd == contact_aft:
		if not hit:
			hit = true
			ring_on.emit()
			return
		else:
			return
	
	if hit:
		ring_off.emit()
		hit = false
