extends Node3D


@export var starting_positions: Array[Node3D]

@export var participating_bugs: Array[DrillBug]


func _ready() -> void:
	prepare_race()

func prepare_race() -> void:
	var i:= 0
	for place in starting_positions:
		participating_bugs[i].global_position = place.global_position
		participating_bugs[i].global_rotation = place.global_rotation
		
		i += 1
		
	await get_tree().create_timer(3).timeout
	for bug in participating_bugs:
		bug.start_race()
