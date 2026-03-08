extends StaticBody3D
@onready var door_anims: AnimationPlayer = $door_anims
func _ready() -> void:
	door_anims.play("close")
func interaction():
	GlScript.shop_open = !GlScript.shop_open
	if GlScript.shop_open:
		door_anims.play("open")
	else:
		door_anims.play("close")

func use_nps():
	if !GlScript.shop_open:
		door_anims.play("open")
		await get_tree().create_timer(3).timeout
		door_anims.play("close")
