extends StaticBody3D
@onready var shalf: Node3D = $"../.."


func interaction(player):
	shalf.transfer_potions_to_shelf()
