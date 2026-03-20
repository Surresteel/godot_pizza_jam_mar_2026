extends Node3D

@export var player: Player
@export var starting_positions: Array[Node3D]

@export var participating_bugs: Array[DrillBug]
@onready var label_3d: Label3D = $Kiosk/Label3D

var bet_amount: int = 100
var bug_betted_on: DrillBug

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

func race_win(winning_bug: DrillBug) -> void:
	if winning_bug == bug_betted_on:
		#player.add_ticket(bet_amount * 2) #TODO add this
		print("winner")
	

func _on_finish_line_body_entered(body: Node3D) -> void:
	if body is DrillBug:
		var bug: DrillBug = body
		if global_basis.z.dot((global_position - bug.global_position).normalized()) > 0:
			bug.current_lap += 1
			print(bug, " is on lap ", bug.current_lap)
			if bug.current_lap == 3:
				race_win(bug)
				for i in participating_bugs:
					i.racing = false
