extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _play_anim(anim_name: String):
	animation_tree["parameters/playback"].travel(anim_name)
