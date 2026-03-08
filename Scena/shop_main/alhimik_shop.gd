extends Node3D
@onready var directional_light_day: DirectionalLight3D = $DirectionalLight_day
@onready var directional_light_night: DirectionalLight3D = $DirectionalLight_night
@onready var trade: AudioStreamPlayer3D = $aurovil/sfx/trade
@onready var sheep: AudioStreamPlayer3D = $aurovil/sfx/sheep
@onready var horney: AudioStreamPlayer3D = $aurovil/sfx/horney
@onready var bird: AudioStreamPlayer3D = $aurovil/sfx/bird
@onready var streed_light: Node3D = $fantasy_game_inn/light/streed_light

func _ready() -> void:
	directional_light_day.visible = GlScript.day
	directional_light_night.visible = !GlScript.day

func _process(delta: float) -> void:

	if Input.is_action_just_pressed("sun"):
		GlScript.day = !GlScript.day
		if GlScript.day:
			trade.play()
			sheep.play()
			horney.play()
			bird.play()
			streed_light.visible = !GlScript.day
			directional_light_day.visible = GlScript.day
			directional_light_night.visible = !GlScript.day
		else:
			directional_light_day.visible = GlScript.day
			directional_light_night.visible = !GlScript.day
			streed_light.visible = !GlScript.day
			trade.stop()
			sheep.stop()
			horney.stop()
			bird.stop()


func _on_bird_finished() -> void:
	bird.play()


func _on_trade_finished() -> void:
	trade.play()


func _on_sheep_finished() -> void:
	sheep.play()

func _on_horney_finished() -> void:
	horney.play()
