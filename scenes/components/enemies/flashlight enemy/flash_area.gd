extends Area3D

@export var message : String

@onready var player : CharacterBody3D = $"../.."
@onready var flashlight_timer : Timer = $FlashlightTimer

var _enemy_spotted : bool = false
var timer : float = 0.0

var sequence = []
var step : int = 0
var _is_blinking : bool = false

const lighting_duration = 3.0

signal scare_enemy

var morse_map = {
	"A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
	"F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
	"K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
	"P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
	"U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--",
	"Z": "--..", "0": "-----", "1": ".----", "2": "..---", "3": "...--",
	"4": "....-", "5": ".....", "6": "-....", "7": "--...", "8": "---..",
	"9": "----.", ".": ".-.-.-", ",": "--..--", "?": "..--..", "!": "-.-.--",
	":": "---...", ";": "-.-.-.", "=": "-...-", "+": ".-.-.", "-": "-....-",
	"/": "-..-.", "@": ".--.-.", "(": "-.--.", ")": "-.--.-", "&": ".-...",
	"\"": ".-..-.", "'": ".----.", "$": "...-..-", "_": "..--.-"
}

func _process(delta : float):
	if _enemy_spotted:
		if not player._is_flashlight_on_player:
			timer = 0.0
			return
		
		#player.flashlight_enemy._is_attacking
		
		timer += delta
		
		if timer > (lighting_duration / 2) and timer < lighting_duration and _is_blinking == false:
			_is_blinking = true
			blink_flashlight()
		
		if timer >= lighting_duration:
			timer = 0.0
			#player._is_flashlight_on_player = false
			emit_signal("scare_enemy")
		

func blink_flashlight():
	player._is_flashlight_locked = true
	build_sequence(message)
	step = 0
	_next_step()

func _next_step():
	if step >= sequence.size():
		player._is_flashlight_locked = false
		_is_blinking = false
		player.toggle_flashlight()
		return
	
	var part = sequence[step]
	
	player.toggle_flashlight()
	flashlight_timer.start(part.duration * 0.05)
	
	step += 1

func build_sequence(text : String):
	sequence.clear()
	
	var upper_text = text.to_upper()
	
	for i in upper_text:
		if i == " ":
			sequence.append({"duration": 7})
		
		var code = morse_map.get(i, "")
		
		for j in code:
			var dur : float = 1.0 if j == "." else 3.0
			
			sequence.append({"duration": dur})
			sequence.append({"duration": 1.0})
		
		sequence.append({"duration": 2.0})

#player.toggle_flashlight()

func _physics_process(_delta: float):
	for body in self.get_overlapping_bodies():
		_enemy_spotted = true if body.is_in_group("Enemigo") else false


func _on_flashlight_timer_timeout() -> void:
	_next_step()
