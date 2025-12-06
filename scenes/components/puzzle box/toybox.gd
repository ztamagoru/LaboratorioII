extends StaticBody3D

@export var correct_combination: Array[int] = [4, 2, 5]
@export var lock_distance: float = 1.5

var current_combination: Array[int] = [0, 0, 0]
var is_unlocked: bool = false
var player_in_area: bool = false
var current_player = null

var sliders_3d: Node3D = null
var dials: Array = []
var slider_camera: Camera3D = null
var sliders_hidden_position: Vector3 = Vector3(0, -1000, 0)
var sliders_visible_position: Vector3 = Vector3(0.072, 0.193, -0.113)

@onready var lid_pivot = $LidPivot
@onready var lock_mesh = $candado
@onready var lock_pivot = $SliderLock
@onready var animation_player = $AnimationPlayer
@onready var lock_animation_player = $AnimationPlayer2

func _ready():
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)
	else:
		push_error("⚠ No se encontró AnimationPlayer")

	sliders_3d = lock_pivot
	if sliders_3d:
		sliders_visible_position = sliders_3d.position
		
		slider_camera = sliders_3d.get_node_or_null("Camera3D")
		if not slider_camera:
			push_error("No se encontró Camera3D en SliderLock")
			return
		
		slider_camera.current = false
		
		sliders_3d.position = sliders_hidden_position
		
		find_dials_recursive(sliders_3d)
		
		if dials.size() == 0:
			push_error("No se encontraron diales en SliderLock")
			return
		
		for i in range(dials.size()):
			if dials[i].has_signal("value_changed"):
				dials[i].value_changed.connect(_on_dial_changed.bind(i))
		
		for dial in dials:
			dial.set_process_input(false)
			dial.set_process_unhandled_input(false)
	else:
		push_error("⚠ No se encontró SliderLock")
	
	var area = get_node_or_null("Area3D")
	if area:
		area.body_entered.connect(_on_area_entered)
		area.body_exited.connect(_on_area_exited)

func find_dials_recursive(node: Node):
	if node is RigidBody3D and node.name.begins_with("LockDial"):
		dials.append(node)
		return
	
	for child in node.get_children():
		find_dials_recursive(child)

func _on_area_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		current_player = body
		
		var crosshair = get_tree().get_first_node_in_group("crosshair")
		if not crosshair:
			crosshair = get_tree().root.get_node_or_null("Game/Crosshair")
		
		if crosshair and crosshair.has_method("set_interactive"):
			crosshair.set_interactive()

func _on_area_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		current_player = null
		
		var crosshair = get_tree().get_first_node_in_group("crosshair")
		if not crosshair:
			crosshair = get_tree().root.get_node_or_null("Game/Crosshair")
		
		if crosshair and crosshair.has_method("set_normal"):
			crosshair.set_normal()

func _input(event):
	if slider_camera and slider_camera.current:
		if not is_unlocked:
			if event.is_action_pressed("ui_close"):
				close_sliders()
				get_viewport().set_input_as_handled()
		return
	
	if player_in_area and not is_unlocked:
		if event.is_action_pressed("interact"):
			open_sliders()
			get_viewport().set_input_as_handled()

func open_sliders():
	if not sliders_3d or dials.size() == 0 or not slider_camera:
		push_error("⚠ No hay sliders, diales o cámara disponibles")
		return
	
	current_combination = [0, 0, 0]
	for dial in dials:
		if dial.has_method("set_value"):
			dial.set_value(0)
	
	if current_player:
		if current_player.has_method("lock_camera"):
			current_player.lock_camera()
		
		if "velocity" in current_player:
			current_player.velocity = Vector3.ZERO
		
		var state_machine = current_player.get_node_or_null("FSM")
		if state_machine:
			state_machine.set_process(false)
			state_machine.set_physics_process(false)
		
		current_player.set_process_input(false)
		current_player.set_process_unhandled_input(false)
	
	var crosshair = get_tree().get_first_node_in_group("crosshair")
	if not crosshair:
		crosshair = get_tree().root.get_node_or_null("Game/Crosshair")
	
	if crosshair:
		crosshair.visible = false
	
	sliders_3d.position = sliders_visible_position
	
	slider_camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	for dial in dials:
		dial.set_process_input(true)
		dial.set_process_unhandled_input(true)

func close_sliders():
	var crosshair = get_tree().get_first_node_in_group("crosshair")
	if not crosshair:
		crosshair = get_tree().root.get_node_or_null("Game/Crosshair")
	
	if crosshair:
		crosshair.visible = true
		if crosshair.has_method("set_normal"):
			crosshair.set_normal()
	
	if sliders_3d:
		sliders_3d.position = sliders_hidden_position
	
	if slider_camera:
		slider_camera.current = false
	
	for dial in dials:
		dial.set_process_input(false)
		dial.set_process_unhandled_input(false)
	
	if current_player:
		var player_camera = current_player.get_node_or_null("PlayerCamera/Camera3D")
		if not player_camera:
			player_camera = current_player.get_node_or_null("Camera3D")
		
		if player_camera and player_camera is Camera3D:
			player_camera.current = true
		
		if current_player.has_method("unlock_camera"):
			current_player.unlock_camera()
		
		var state_machine = current_player.get_node_or_null("FSM")
		if state_machine:
			state_machine.set_process(true)
			state_machine.set_physics_process(true)
		
		current_player.set_process_input(true)
		current_player.set_process_unhandled_input(true)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_dial_changed(new_value: int, index: int):
	if index >= 0 and index < current_combination.size():
		current_combination[index] = new_value
		check_combination()

func check_combination():
	if is_unlocked:
		return
	
	var correct = true
	for i in range(min(current_combination.size(), correct_combination.size())):
		if current_combination[i] != correct_combination[i]:
			correct = false
			break
	
	if correct:
		unlock_box()

func unlock_box():
	is_unlocked = true
	close_sliders()
	await get_tree().create_timer(0.3).timeout
	play_lock_drop_animation()
	await get_tree().create_timer(0.5).timeout
	play_open_animation()

func play_lock_drop_animation():
	if not lock_animation_player:
		push_error("⚠ No hay AnimationPlayer2 para el candado")
		return
	
	if lock_animation_player.has_animation("candado_caer"):
		lock_animation_player.play("candado_caer")
	else:
		var anim_list = lock_animation_player.get_animation_list()
		if anim_list.size() > 0:
			lock_animation_player.play(anim_list[0])
		else:
			push_error("⚠ No hay animaciones en AnimationPlayer2")

func play_open_animation():
	if animation_player.is_playing():
		return
	animation_player.play("abrir_cofre")
	
	if animation_player.is_playing():
		return
	
	if animation_player.has_animation("abrir_cofre"):
		animation_player.play("abrir_cofre")
		print("📦 Abriendo cofre...")
	else:
		push_error("⚠ No se encontró la animación 'abrir_cofre'")

func _on_animation_finished(anim_name):
	if anim_name == "abrir_cofre":
		print("Cofre abierto!")
