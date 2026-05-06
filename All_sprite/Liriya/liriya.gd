extends CharacterBody3D

@export var target: Node3D 
@export var speed = 5.0  


@onready var nav_agent: NavigationAgent3D = $Navigation_liriya 

func _physics_process(_delta):
	
	if not target:
		return


	nav_agent.target_position = target.global_position
	
	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO 
		return

	var current_pos = global_transform.origin
	var next_path_pos = nav_agent.get_next_path_position()
	
	var direction = current_pos.direction_to(next_path_pos)
	
	#direction.y = 0 
	#direction = direction.normalized()

	velocity = direction * speed

	move_and_slide()
