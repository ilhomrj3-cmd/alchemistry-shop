extends Node3D
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
var s = false
@onready var trade: AudioStreamPlayer3D = $aurovil/sfx/trade
@onready var sheep: AudioStreamPlayer3D = $aurovil/sfx/sheep
@onready var horney: AudioStreamPlayer3D = $aurovil/sfx/horney
@onready var bird: AudioStreamPlayer3D = $aurovil/sfx/bird

func _ready() -> void:
	directional_light_3d.visible = false

func _process(delta: float) -> void:

	if Input.is_action_just_pressed("sun"):
		trade.play()
		sheep.play()
		horney.play()
		bird.play()	
		s = !s 
		directional_light_3d.visible = s


func _on_bird_finished() -> void:
	bird.play()


func _on_trade_finished() -> void:
	trade.play()


func _on_sheep_finished() -> void:
	sheep.play()

func _on_horney_finished() -> void:
	horney.play()
