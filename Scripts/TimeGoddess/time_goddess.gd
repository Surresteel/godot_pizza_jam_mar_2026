class_name TimeGoddess
extends StaticBody3D

@onready var _anim_player: AnimationPlayer = \
		$TimeGoddessAnimationsDone/AnimationPlayer


# INTERACTABLE:
@onready var interactable: Interactable = $Interactable
var sparks_scene: PackedScene = preload("uid://cw58ajifadxqd")

@onready var p_spawn: Node3D = $PSpawn
var _is_telling_fortune: bool = false


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	interactable.activated.connect(_tell_fortune)


func _tell_fortune() -> void:
	_play_anim("Talking Spell")
	var fx: GPUParticles3D = sparks_scene.instantiate()
	get_tree().current_scene.add_child(fx)
	fx.global_position = p_spawn.global_position
	_is_telling_fortune = true
	interactable.toggle(false)
	await get_tree().create_timer(5).timeout
	_is_telling_fortune = false
	interactable.toggle(true)


#===============================================================================
#	FUNCTIONS - ANIMATIONS:
#===============================================================================
func _play_anim(anim: String, blend: float = 1, play_spd: float = 1.0) -> void:
	_anim_player.play(anim, blend, play_spd)
	_anim_player.queue("Talking2")
