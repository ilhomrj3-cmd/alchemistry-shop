extends CharacterBody3D

@onready var anim_tree: AnimationTree = $main_character/Player_AnimationTree

@onready var anim_state: AnimationNodeStateMachinePlayback
@onready var cam = $Camera3D
@onready var mesh_rotate = $main_character


var shield_equipped := false
var is_blocking := false


@export var base_speed := 4.0
@export var run_speed := 7.0
@export var shield_speed := 3.5
@export var shield_run_speed := 6.5

var SPEED := 4.0

func _ready():
	anim_tree.active = true
	anim_state = anim_tree.get("parameters/StateMachine/playback")


func _input(event):
	if event.is_action_pressed("shield_toggle"):
		shield_equipped = !shield_equipped
		is_blocking = false 


	if shield_equipped:
		if event.is_action_pressed("block"):
			
			is_blocking = true
		elif event.is_action_released("block"):
			is_blocking = false



func _physics_process(delta):

	var input = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var is_running = Input.is_action_pressed("ui_run")

	if is_running and input.y > 0:
		input.y = 0


	if is_blocking:
		velocity = Vector3.ZERO
		update_animation(Vector2.ZERO)
		move_and_slide()
		return


	look_at_mouse()


	var forward = -mesh_rotate.global_transform.basis.z
	var right = -mesh_rotate.global_transform.basis.x

	forward.y = 0
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()

	var direction = (forward * input.y + right * input.x)


	if shield_equipped:
		SPEED = shield_run_speed if is_running else shield_speed
	else:
		SPEED = run_speed if is_running else base_speed


	if direction != Vector3.ZERO:
		direction = direction.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	update_animation(input)


	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	move_and_slide()


func update_animation(input: Vector2):

	if is_blocking:
		anim_state.travel("block")
		return

	var is_running := Input.is_action_pressed("ui_run")


	if input == Vector2.ZERO:
		if shield_equipped:
			anim_state.travel("idle_with_shield")
		else:
			anim_state.travel("idle")
		return


	if abs(input.y) > abs(input.x):

		if input.y < 0:
			if is_running:
				if shield_equipped:
					anim_state.travel("run_with_shild_forward")
				else:
					anim_state.travel("run_forward")
			else:
				if shield_equipped:
					anim_state.travel("walk_with_shild_forward")
				else:
					anim_state.travel("walk_forward")

		else:
			if not is_running:
				if shield_equipped:
					anim_state.travel("walk_with_shild_backward")
				else:
					anim_state.travel("walk_backward")

	else:
		if input.x > 0:
			if shield_equipped:
				anim_state.travel("walk_with_shild_right")
			else:
				anim_state.travel("walk_right")
		else:
			if shield_equipped:
				anim_state.travel("walk_with_shild_left")
			else:
				anim_state.travel("walk_left")

func look_at_mouse():
	var mouse_pos = get_viewport().get_mouse_position()

	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * 1000

	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space.intersect_ray(query)

	if result:
		var hit = result.position
		hit.y = mesh_rotate.global_position.y
		mesh_rotate.look_at(hit, Vector3.UP)
		mesh_rotate.rotate_y(deg_to_rad(180))
