extends Area3D

signal player_sat_down
signal player_stood_up

@export var sit_position: Marker3D
@export var prompt_label: Label3D

var player_in_range: bool = false
var player_is_sitting: bool = false
var player_ref: Node3D = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if prompt_label:
		prompt_label.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body

		if prompt_label:
			prompt_label.visible = true
			prompt_label.text = "[E] Sentarse"

func _on_body_exited(body):
	if body.is_in_group("player") and not player_is_sitting:
		player_in_range = false
		player_ref = null

		if prompt_label:
			prompt_label.visible = false

func _input(event):
	# SENTARSE con E
	if player_in_range and not player_is_sitting:
		if event is InputEventKey and event.pressed and event.keycode == KEY_E:
			sit_down()
		elif event.is_action_pressed("interact"):
			sit_down()
	
	# LEVANTARSE con Espacio
	elif player_is_sitting and event.is_action_pressed("ui_accept"):
		stand_up()

func sit_down():
	if not player_ref:
		return
	
	if not sit_position:
		return
	
	player_is_sitting = true

	# Mover al jugador
	player_ref.global_position = sit_position.global_position
	player_ref.global_rotation = sit_position.global_rotation
	
	# Desactivar movimiento
	if player_ref.has_method("set_can_move"):
		player_ref.set_can_move(false)
	else:
		player_ref.set_physics_process(false)
	
	if prompt_label:
		prompt_label.visible = false
	
	# AVISAR A LA RADIO
	player_sat_down.emit()

func stand_up():
	if not player_is_sitting:
		return
	
	player_is_sitting = false
	
	# Reactivar movimiento
	if player_ref:
		if player_ref.has_method("set_can_move"):
			player_ref.set_can_move(true)
		else:
			player_ref.set_physics_process(true)
		
		# Mover un poco adelante
		player_ref.global_position += player_ref.global_transform.basis.z * 1.0
	
	# AVISAR A LA RADIO
	player_stood_up.emit()
	
	if player_in_range and prompt_label:
		prompt_label.visible = true
