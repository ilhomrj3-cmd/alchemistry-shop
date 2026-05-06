extends Node3D
@onready var eye: Node3D = $Node3D/flask_obj_cleaner_materialmerger_gles/eye
@onready var lamp: AudioStreamPlayer3D = $"Node3D/flask_obj_cleaner_materialmerger_gles/Sketchfab_Scene/Sketchfab_model/7bdce573fa4f4345b532d79e2adc2223_fbx/Object_2/RootNode/Object_4/Object003/lamp_sfx"

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scena/shop_main/alhimik_shop.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_lamp_sfx_finished() -> void:
	lamp.play()
