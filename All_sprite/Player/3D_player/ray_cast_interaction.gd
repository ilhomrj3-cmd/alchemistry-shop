extends RayCast3D
@onready var player_shop: CharacterBody3D = $"../.."

@onready var sprite_interaction: Sprite3D = $"../Sprite_interaction"


func _process(delta: float) -> void:
	if is_colliding():
		var hitobj = get_collider()
		if hitobj.has_method("interaction"):
			sprite_interaction.visible = true
		else:
			sprite_interaction.visible = false
		if hitobj.has_method("interaction") and Input.is_action_just_pressed("interaction"):
			hitobj.interaction()
			player_shop.uptade_all_slot()
	else:
		sprite_interaction.visible = false
