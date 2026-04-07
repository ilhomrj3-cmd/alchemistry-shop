extends StaticBody3D

func interaction(player):
	if player.is_in_group("player"):
		player.start_price_ui()
		
