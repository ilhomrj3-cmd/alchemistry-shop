extends RayCast3D
@onready var player_shop: CharacterBody3D = $"../.."

func _process(delta: float) -> void:
	if is_colliding():
		player_shop.player_up()
