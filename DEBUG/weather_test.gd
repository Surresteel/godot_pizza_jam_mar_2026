extends Node3D

@onready var ui: UserInterface = $UI


func _ready() -> void:
	if ui:
		UiManager.ui = ui
	call_deferred("_ready_deferred")


func _ready_deferred() -> void:
	var world_env := WorldEnvironment.new()
	get_tree().current_scene.add_child(world_env)
	WeatherManager.world_env = world_env
	WeatherManager.switch_weather(WeatherManager.WEATHER.SUN)
	GameManager.switch_game(GameManager.GAME.NONE)
	
