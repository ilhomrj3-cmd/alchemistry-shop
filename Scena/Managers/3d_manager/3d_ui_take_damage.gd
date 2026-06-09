extends Node3D
@onready var damage_lable_anim: AnimationPlayer = $damage_lable_anim
@onready var damage_lable: Label3D = $damage_lable
func _play_anim_damage_poin_take(amount: int):
	damage_lable.text = str(amount)
	damage_lable_anim.play("take_damage")
	await damage_lable_anim.animation_finished
	queue_free()
