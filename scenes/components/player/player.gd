extends CharacterBody3D

@export var animation_player : AnimationPlayer

@export var flashlight : SpotLight3D

const speed : float = 5.0
const sprint_multiplier : float = 3.0
const crouch_speed : float = 4.0

var current_speed : float = speed

const walking_head_bop : float = 2.0

const jump_force : float = 3.5
const jump_velocity : float = 4.5
const gravity : float = 8.0

const flashlight_energy : float = 15.0

var _is_crouching : bool = false
var _is_flashlight_on : bool = false

func _ready() -> void:
	flashlight.light_energy = 0

func _process(_delta) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func _input(event):
	if event.is_action_pressed("move_crouch"):
		toggle_crouch()
	
	if event.is_action_pressed("flashlight"):
		toggle_flashlight()
	
	if event.is_action_pressed("move_sprint"):
		current_speed = speed * sprint_multiplier
	
	if event.is_action_released("move_sprint"):
		current_speed = speed

func toggle_flashlight():
	_is_flashlight_on = !_is_flashlight_on
	
	if _is_flashlight_on:
		flashlight.light_energy = flashlight_energy
	else:
		flashlight.light_energy = 0.0
	

func toggle_crouch():
	if _is_crouching:
		animation_player.play("crouch", -1, -crouch_speed, true)
	else:
		animation_player.play("crouch", -1, crouch_speed, false)
	#print("is crouching: ", _is_crouching)
	_is_crouching = !_is_crouching
