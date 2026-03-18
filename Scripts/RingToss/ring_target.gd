#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name RingTarget
extends StaticBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================

signal ring_on(target: RingTarget)

# GAME:
var contact_fwd: Node3D = null
var contact_aft: Node3D = null
@onready var area_fwd: Area3D = $AreaFwd
@onready var area_aft: Area3D = $AreaAft
var hit: bool = false


#===============================================================================
#	CALLBACKS:
#===============================================================================

# Node initialisation:
func _ready() -> void:
	# Connect collision signals:
	area_fwd.body_entered.connect(func(node): contact_fwd = node)
	area_fwd.body_exited.connect(func(_node): contact_fwd = null)
	area_aft.body_entered.connect(func(node): contact_aft = node)
	area_aft.body_exited.connect(func(_node): contact_aft = null)


# Node behaviour:
func _process(_delta: float) -> void:
	if contact_fwd and contact_aft and contact_fwd == contact_aft:
		if not hit:
			hit = true
			print("RING ON")
			ring_on.emit(self)
			return
		else:
			return
	
	hit = false

#===============================================================================
#	EOF:
#===============================================================================
