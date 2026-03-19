#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name UserInterface
extends CanvasLayer


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# UI ELEMENTS - GENERAL:
@onready var fade_rect: ColorRect = $FadeOut

# UI ELEMENTS - COMMON AREA:
@onready var game_ui_none: Control = $GameUINone
@onready var interact_prompt: Label = $GameUINone/InteractPrompt

# UI ELEMENTS - RING TOSS:
@onready var game_ui_ring: Control = $GameUIRing
@onready var rings_left: Label = $GameUIRing/RingsLeft
@onready var ring_power: ColorRect = $GameUIRing/RingPower
var _col_power_low := Color.FIREBRICK
var _col_power_high := Color.GREEN

# UI ELEMENTS - COPYCAT:
@onready var game_ui_copycat: Control = $GameUICopycat
@onready var timer: Label = $GameUICopycat/Timer
@onready var guesses: Label = $GameUICopycat/Guesses



#===============================================================================
#	CALLBACKS:
#===============================================================================
# Node initialisation:
func _ready() -> void:
	GameManager.game_change.connect(_on_game_change)
	WeatherManager.weather_change.connect(_on_weather_changed)
	pass


# Trigger fade out / in on weather change:
func _on_weather_changed(_old: WeatherManager.WEATHER, 
		_new: WeatherManager.WEATHER) -> void:
	fade_out_in(1.0, 0.0, 1.0)


#===============================================================================
#	FUNCTIONS - LAYOUT:
#===============================================================================
# Changes the user interface based on which game is active:
func _on_game_change(_old: GameManager.GAME, new: GameManager.GAME) -> void:
	# Reset visibility:
	game_ui_none.visible = false
	game_ui_ring.visible = false
	game_ui_copycat.visible = false
	
	match new:
		GameManager.GAME.NONE:
			game_ui_none.visible = true
		GameManager.GAME.HAMMER:
			pass
		GameManager.GAME.RING:
			game_ui_ring.visible = true
		GameManager.GAME.DRILL:
			pass
		GameManager.GAME.COPYCAT:
			game_ui_copycat.visible = true


#===============================================================================
#	FUNCTIONS - COMMON AREA:
#===============================================================================
# Updates the interact prompt:
func update_interact_prompt(msg: String = "", vis: bool = true) -> void:
	interact_prompt.text = msg
	interact_prompt.visible = vis


#===============================================================================
#	FUNCTIONS - RING TOSS:
#===============================================================================
# Sets the ring power:
func set_ring_power(power: float) -> void:
	power = clampf(power, 0.0, 1.0)
	ring_power.scale.y = power * 3.5
	ring_power.color = _col_power_low.lerp(_col_power_high, power)
	
	return


func set_ring_count(c: int, max_c: int) -> void:
	rings_left.text = str(c) + "/" + str(max_c)
	return


#===============================================================================
#	FUNCTIONS - COPYCAT:
#===============================================================================
func set_timer(t: int) -> void:
	timer.text = str(t)


func set_guesses(g: int) -> void:
	guesses.text = "Guesses: " + str(g)


#===============================================================================
#	FUNCTIONS - TRANSITIONS:
#===============================================================================
# Fades the screen to black and back again:
func fade_out_in(t_out: float, t_hold: float, t_in: float) -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, t_out).from(0.0)
	tween.tween_interval(t_hold)
	tween.tween_property(fade_rect, "modulate:a", 0.0, t_in)
