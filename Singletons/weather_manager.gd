#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# WEATHER:
enum WEATHER{SUN, RAIN}
signal weather_change(old: WEATHER, new: WEATHER)
var current_weather := -1
var world_env: WorldEnvironment = null
var rain_scene: PackedScene = preload("uid://ggi604yby8ce")
var rain: Rain = null

# ENVIRONMENTS:
var env_rain: Environment = preload("uid://d07txaagus1nm")
var env_sun: Environment = preload("uid://btlqkky7jn2ja")
var env_arr: Array[Environment] = [env_sun, env_rain]

# LIGHTS:
var light: DirectionalLight3D = null
var light_sun: PackedScene = preload("uid://46yi8b2qmfku")
var light_rain: PackedScene = preload("uid://dlg5t05uh0pqh")
var light_arr: Array[PackedScene] = [light_sun, light_rain]


#===============================================================================
#	FUNCTIONS - WEATHER:
#===============================================================================
# Switches the scene weather:
func switch_weather(new_weather: WEATHER) -> void:
	# GATE - new weather must be different from current:
	if new_weather == current_weather:
		return
	
	# Update weather:
	weather_change.emit(current_weather, new_weather)
	_toggle_rain(new_weather == WEATHER.RAIN)
	current_weather = new_weather
	
	# GATE - World environment must exist:
	if not world_env:
		return
	
	# Update environment:
	await get_tree().create_timer(1.0).timeout
	world_env.environment = env_arr[current_weather]
	
	# Update lights:
	if light:
		light.queue_free()
	light = light_arr[current_weather].instantiate()
	get_tree().current_scene.add_child(light)
	
	return


# Toggles the rain particle system:
func _toggle_rain(turn_on: bool) -> void:
	if not turn_on:
		if rain:
			rain.queue_free()
	else:
		if not rain:
			rain = rain_scene.instantiate()
			get_tree().current_scene.add_child(rain)
			
	return
