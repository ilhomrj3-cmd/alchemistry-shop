extends Control
@onready var dangin_player: CharacterBody3D = $"../../../../.."
var inv_manager_but_in_no_global: bool = false
func _physics_process(_delta):

	if Input.is_action_just_pressed("menu_inventory"):
		GlScript.inv_act = !GlScript.inv_act
		inv_manager_but_in_no_global = !inv_manager_but_in_no_global
		if GlScript.inv_act or inv_manager_but_in_no_global:
			dangin_player.dont_move_okey = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			visible = true
		else:
			dangin_player.dont_move_okey = false
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			visible = false
	
