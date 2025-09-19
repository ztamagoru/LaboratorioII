extends Area3D

@export var flashlight : SpotLight3D
@onready var shape: CollisionShape3D = $CollisionShape3D
@onready var player : CharacterBody3D = $"../../.."

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

#func _process(delta: float) -> void:
	#if spot_light and shape.shape is BoxShape3D:
		#var range = spot_light.spot_range
		#var angle = deg_to_rad(spot_light.spot_angle)
#
		## Calculamos tamaño del box para imitar el cono
		#var box_size = Vector3(
			#tan(angle / 2.0) * range,   # ancho según el ángulo
			#tan(angle / 2.0) * range,   # alto según el ángulo
			#range                      # profundidad = alcance
		#)
#
		#shape.shape.size = box_size * 2.0           # tamaño completo del box
		#shape.position = Vector3(0, 0, -range / 2)  # mover hacia adelante

#func _on_body_entered(body: Node) -> void:
	#if body.is_in_group("Enemigo"):
		#if player._is_flashlight_on:
			#print("Dentro")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Enemigo") and player._is_flashlight_on:
		print("Dentro")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Enemigo"):
		print("Fuera")
