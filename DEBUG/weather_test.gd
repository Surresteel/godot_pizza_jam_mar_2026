extends Node3D


var timeout: float = 5000.0
var cooldown: float = 5000.0
var idx: int = 0
var w_arr: Array = WeatherManager.WEATHER.values()

@onready var ui: UserInterface = $UI


func _ready() -> void:
	if ui:
		UiManager.ui = ui
	call_deferred("_ready_deferred")


func _ready_deferred() -> void:
	var world_env := WorldEnvironment.new()
	get_tree().current_scene.add_child(world_env)
	WeatherManager.world_env = world_env
	WeatherManager.switch_weather(WeatherManager.WEATHER.RAIN)
	GameManager.switch_game(GameManager.GAME.NONE)


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() < timeout:
		return
	idx = (idx + 1) % w_arr.size()
	#var new_weather = w_arr[idx]
	#WeatherManager.switch_weather(new_weather)
	timeout += cooldown
	
