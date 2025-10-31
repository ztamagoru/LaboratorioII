extends CharacterBody3D

@export var animation_player : AnimationPlayer

@export var flashlight : SpotLight3D

@onready var stamina_cd_timer : Timer = $StaminaRecoveryTimer

const speed : float = 5.0
const sprint_multiplier : float = 2.0
const crouch_speed : float = 4.0

const max_stamina : float = 100.0
const stamina_consumption : float = 30.0
const stamina_recovery : float = 7.0
const stamina_recovery_cd : float = 0.75
var stamina : float

var current_speed : float = speed

const walking_head_bop : float = 2.0
const running_head_bop : float = 5.0

const jump_force : float = 3.5
const jump_velocity : float = 4.5
const gravity : float = 8.0

const flashlight_energy : float = 15.0

var _is_crouching : bool = false
var _is_flashlight_on : bool = false
var _is_running : bool = false
var _is_recovering_stamina : bool = false

func _ready():
	stamina = max_stamina
	
	Globals.player = self
	flashlight.light_energy = 0

func _process(delta : float):
	#print(stamina)
	
	if _is_running and stamina > 0:
		stamina -= stamina_consumption * delta
		
	elif _is_running and stamina <= 0:
		_is_running = !_is_running
		current_speed = speed
		stamina_cd_timer.start(stamina_recovery_cd)
	
	if !_is_running and stamina < max_stamina:
		if _is_recovering_stamina:
			stamina += stamina_recovery * delta
			
			if stamina >= max_stamina:
				_is_recovering_stamina = !_is_recovering_stamina
	
	stamina = max_stamina if stamina > max_stamina else 0 if stamina < 0 else stamina
	
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func _input(event):
	if event.is_action_pressed("move_crouch"):
		animation_player.play("crouch", -1, crouch_speed, false)
		_is_crouching = true
	
	if event.is_action_released("move_crouch"):
		animation_player.play("crouch", -1, -crouch_speed, true)
		_is_crouching = false
	
	if event.is_action_pressed("flashlight"):
		toggle_flashlight()
	
	if event.is_action_pressed("move_sprint"):
		current_speed = speed * sprint_multiplier
		_is_running = true
		
		if _is_recovering_stamina:
			_is_recovering_stamina = !_is_recovering_stamina
		
		if stamina_cd_timer.time_left > 0:
			stamina_cd_timer.stop()
	
	if event.is_action_released("move_sprint"):
		if _is_running:
			current_speed = speed
			_is_running = false
			
			stamina_cd_timer.start(stamina_recovery_cd)

func toggle_flashlight():
	_is_flashlight_on = !_is_flashlight_on
	
	if _is_flashlight_on:
		flashlight.light_energy = flashlight_energy
	else:
		flashlight.light_energy = 0.0

func _on_stamina_recovery_timer_timeout() -> void:
	_is_recovering_stamina = true
