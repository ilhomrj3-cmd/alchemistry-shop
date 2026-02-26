extends Node3D

@onready var fair_sound: AudioStreamPlayer3D = $fair_sound


func _on_fair_sound_finished() -> void:
	fair_sound.play()
