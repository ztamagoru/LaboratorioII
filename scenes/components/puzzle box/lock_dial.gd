extends RigidBody3D

signal value_changed(new_value)

var _is_rotating : bool = false
var rotation_speed : float = 0.05

var value : int = 0

const STEP_DEGREES : float = 36.0

func _ready():
	gravity_scale = 0
	freeze = false
	contact_monitor = false
	continuous_cd = true

func _input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: 
				_is_rotating = _is_mouse_over()
			else:
				if _is_rotating: 
					snap_to_closest()
				_is_rotating = false
	
	if _is_rotating and event is InputEventMouseMotion:
		rotate_y(event.relative.x * rotation_speed)

func _is_mouse_over():
	var cam = get_viewport().get_camera_3d()
	if cam == null:
		print("No hay Camera3D activa en el Viewport")
		return false
	
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mouse_pos)
	var direction = cam.project_ray_normal(mouse_pos)
	
	var query = PhysicsRayQueryParameters3D.new()
	
	query.from = origin
	query.to = origin + direction * 1000.0
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result and result.collider == self:
		return true
	
	return false

func snap_to_closest():
	var current : float = rotation_degrees.y
	var closest_step = round(current / STEP_DEGREES) * STEP_DEGREES
	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", closest_step, 0.1)
	
	var raw_value = -round(closest_step / STEP_DEGREES)
	var old_value = value
	value = (int(raw_value) % 10 + 10) % 10
	
	print("current value of " + name + " is " + str(value))
	
	if old_value != value:
		emit_signal("value_changed", value)

func get_value() -> int:
	return value

func set_value(new_value: int):
	value = new_value
	rotation_degrees.y = -(new_value * STEP_DEGREES)
