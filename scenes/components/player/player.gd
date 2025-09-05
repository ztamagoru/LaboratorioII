extends CharacterBody3D

const speed : float = 5.0
const jump_force : float = 3.5
const jump_velocity : float = 4.5
const gravity : float = 8.0

func _process(_delta) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
