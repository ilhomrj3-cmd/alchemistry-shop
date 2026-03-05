extends MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var f_sfx: AudioStreamPlayer3D = $fature_sfx
func _ready() -> void:
	animation_player.play("new_animation")


func _on_fature_sfx_finished() -> void:
	f_sfx.play()
