extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var current_anim: String = ""
func _crossbow_play_anim(anim_name: String):
	if current_anim != anim_name:
		current_anim = anim_name
	else:
		return
	if anim_name == "reload":
		animation_player.play_backwards("reload")
	else:
		animation_player.play(anim_name)
