extends Node3D

@export var camera_sensitivity : float
@export var interaction_distance: float = 3.0

var crosshair: CanvasLayer = null
var current_interactable: Area3D = null

@onready var camera: Camera3D = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Buscar el crosshair
	await get_tree().process_frame
	crosshair = get_tree().root.get_node_or_null("Game/Crosshair")
	if not crosshair:
		push_warning("Crosshair no encontrado")

func _input(event: InputEvent) -> void:
	var player = get_parent()
	if player and player.get("camera_locked") and player.camera_locked:
		return
	
	if event is InputEventMouseMotion:
		get_parent().rotate_y(deg_to_rad(-event.relative.x * camera_sensitivity))
		rotate_x(deg_to_rad(-event.relative.y * camera_sensitivity))
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if event.is_action_pressed("interact") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		interact_with_target()

func _physics_process(_delta):
	var player = get_parent()
	if player and player.get("camera_locked") and player.camera_locked:
		return
	
	check_center_raycast()

func check_center_raycast():
	if not camera:
		return
	
	var space_state = get_world_3d().direct_space_state
	
	var viewport_center = get_viewport().get_size() / 2
	var from = camera.project_ray_origin(viewport_center)
	var to = from + camera.project_ray_normal(viewport_center) * interaction_distance
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1
	
	var result = space_state.intersect_ray(query)
	
	if result and result.collider:
		if result.collider.is_in_group("lock_interactable"):
			if current_interactable != result.collider:
				print("Detectado: ", result.collider.name)
			current_interactable = result.collider
			if crosshair:
				crosshair.set_interactive()
			return
	
	if current_interactable != null:
		current_interactable = null
		if crosshair:
			crosshair.set_normal()

func interact_with_target():
	if current_interactable:
		print("Interactuando con: ", current_interactable.name)
		if current_interactable.has_method("open_lock_interface"):
			current_interactable.open_lock_interface()
