extends RayCast3D
func _ready():
 enabled = true

func _process(delta):
 if not is_colliding():
  return

 if Input.is_action_just_pressed("interact"):
  var collider = get_collider()
  if collider and collider.has_method("interact"):
   collider.interact()
