#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name UserInterface
extends CanvasLayer


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# UI ELEMENTS:
@onready var fade_rect: ColorRect = $FadeOut


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Node initialisation:
func _ready() -> void:
	WeatherManager.weather_change.connect(_on_weather_changed)
	pass


# Trigger fade out / in on weather change:
func _on_weather_changed(_old: WeatherManager.WEATHER, 
		_new: WeatherManager.WEATHER) -> void:
	fade_out_in(1.0, 0.0, 1.0)


#===============================================================================
#	FUNCTIONS - TRANSITIONS:
#===============================================================================
# Fades the screen to black and back again:
func fade_out_in(t_out: float, t_hold: float, t_in: float) -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, t_out).from(0.0)
	tween.tween_interval(t_hold)
	tween.tween_property(fade_rect, "modulate:a", 0.0, t_in)
