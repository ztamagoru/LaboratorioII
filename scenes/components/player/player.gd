extends CharacterBody3D

@export var animation_player : AnimationPlayer

const speed : float = 5.0
const crouch_speed : float = 6.0
const jump_force : float = 3.5
const jump_velocity : float = 4.5
const gravity : float = 8.0

var _is_crouching : bool = false

func _process(_delta) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func _input(event):
	if event.is_action_pressed("move_crouch"):
		toggle_crouch()

func toggle_crouch():
	if _is_crouching:
		animation_player.play("crouch", -1, -crouch_speed, true)
	else:
		animation_player.play("crouch", -1, crouch_speed, false)
	#print("is crouching: ", _is_crouching)
	_is_crouching = !_is_crouching
