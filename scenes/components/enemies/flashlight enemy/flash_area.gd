extends Area3D

@onready var player : CharacterBody3D = $"../.."

var _enemy_spotted : bool = false

signal scare_enemy

func _process(_delta : float):
	if _enemy_spotted:
		if player._is_flashlight_on:
			emit_signal("scare_enemy")
		#else:
			#print("está en el área, pero la linterna está apagada")

func _physics_process(_delta: float):
	for body in self.get_overlapping_bodies():
		_enemy_spotted = true if body.is_in_group("Enemigo") else false
