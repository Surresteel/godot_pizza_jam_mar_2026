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
var contact_fwd: bool = false
var contact_aft: bool = false
@onready var area_fwd: Area3D = $AreaFwd
@onready var area_aft: Area3D = $AreaAft
var hit: bool = false


#===============================================================================
#	CALLBACKS:
#===============================================================================

# Node initialisation:
func _ready() -> void:
	# Connect collision signals:
	area_fwd.body_entered.connect(func(_node): contact_fwd = true)
	area_fwd.body_exited.connect(func(_node): contact_fwd = false)
	area_aft.body_entered.connect(func(_node): contact_aft = true)
	area_aft.body_exited.connect(func(_node): contact_aft = false)


# Node behaviour:
func _process(_delta: float) -> void:
	if contact_fwd and contact_aft:
		if not hit:
			hit = true
			print("RING ON")
			ring_on.emit(self)
		else:
			return
	
	hit = false

#===============================================================================
#	EOF:
#===============================================================================
