extends Node3D

@onready var ui: UserInterface = $UI

func _ready() -> void:
	UiManager.ui = ui
