extends Node3D

@export var camera_sensitivity : float

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		get_parent().rotate_y(deg_to_rad(-event.relative.x * camera_sensitivity))
		rotate_x(deg_to_rad(-event.relative.y * camera_sensitivity))
		
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
