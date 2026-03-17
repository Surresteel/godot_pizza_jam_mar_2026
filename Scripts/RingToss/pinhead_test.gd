extends CharacterBody3D


@onready var physics_bones: PhysicalBoneSimulator3D = \
		$SP0RingTossUnfinished/Armature/Skeleton3D/PhysicalBoneSimulator3D

func _ready() -> void:
	physics_bones.active = true
	physics_bones.physical_bones_start_simulation(["Head"])
