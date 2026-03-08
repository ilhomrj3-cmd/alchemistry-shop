extends Camera3D

@export_group("Settings")
@export var mouse_sensitivity: float = 0.1
@export var default_fov: float = 75.0
@export var zoom_fov: float = 50.0

@export_group("Head Bobbing")
@export var bob_freq: float = 2.0  # Частота синуса (как часто качается)
@export var bob_amp: float = 0.08  # Амплитуда (как высоко качается)
@export var bob_side_amp: float = 0.05 # Качание влево-вправо

@export_group("Movement Physics")
@export var smooth_speed: float = 10.0 # Плавность движения камеры

var time: float = 0.0
@onready var player = get_parent() # Предполагаем, что камера — дочерний узел игрока

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	fov = default_fov

func _input(event):
	if event is InputEventMouseMotion:
		player.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		rotation.x = clamp(rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _process(delta):
	# Зум (при нажатии правой кнопки мыши)
	var target_fov = zoom_fov if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) else default_fov
	fov = lerp(fov, target_fov, delta * 8.0)

	# Рассчитываем покачивание
	_handle_head_bob(delta)

func _handle_head_bob(delta):
	# Если игрок движется, увеличиваем время для синуса
	var horizontal_velocity = Vector2(player.velocity.x, player.velocity.z).length()
	
	if player.is_on_floor() and horizontal_velocity > 0.1:
		time += delta * horizontal_velocity * (bob_freq / 2.0)

	# Магия синуса
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq * 0.5) * bob_side_amp
	
	# Применяем позицию камеры (смещение относительно центра игрока)
	transform.origin = lerp(transform.origin, pos, delta * smooth_speed)
