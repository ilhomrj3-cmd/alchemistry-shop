extends StaticBody3D
@onready var door_anims: AnimationPlayer = $door_anims
var door = false
func _ready() -> void:
	door_anims.play("close")
func interaction():
	door = !door
	if door:
		door_anims.play("open")
	else:
		door_anims.play("close")

func use_nps():
	if !door:
		door_anims.play("open")
		await get_tree().create_timer(3).timeout
		door_anims.play("close")
