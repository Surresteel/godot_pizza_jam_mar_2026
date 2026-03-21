class_name WeatherSign
extends StaticBody3D

@onready var arrow_up: MeshInstance3D = $WeatherSign/UpArrow
@onready var arrow_down: MeshInstance3D = $WeatherSign/DownArrow

# INTERACTABLE:
@onready var interactable: Interactable = $Interactable

# WEATHER:
var cur_weather := -1


func _ready() -> void:
	arrow_down.visible = false
	arrow_up.visible = false
	WeatherManager.weather_change.connect(_on_weather_change)
	interactable.activated.connect(_on_interaction)
	cur_weather = WeatherManager.current_weather


func _on_weather_change(_old: WeatherManager.WEATHER, 
		new: WeatherManager.WEATHER) -> void:
	if new == WeatherManager.WEATHER.SUN:
		arrow_up.visible = true
		arrow_down.visible = false
	else:
		arrow_up.visible = false
		arrow_down.visible = true
	
	cur_weather = new


func _on_interaction() -> void:
	if cur_weather == WeatherManager.WEATHER.SUN:
		WeatherManager.switch_weather(WeatherManager.WEATHER.RAIN)
	else:
		WeatherManager.switch_weather(WeatherManager.WEATHER.SUN)
