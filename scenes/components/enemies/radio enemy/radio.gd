extends RigidBody3D

@export var radio_music : AudioStreamPlayer3D

@export var pause_timer : Timer
@export var playing_timer : Timer

const pause_min : int = 10
const pause_max : int = 20

const play_min : int = 25
const play_max : int = 50

func _ready():
	radio_music.play(0.0)
	playing_timer.start(float(random_duration(play_min, play_max)))

func _on_playing_timer_timeout() -> void:
	radio_music.stop()
	pause_timer.start(float(random_duration(pause_min, pause_max)))

func _on_pause_timer_timeout() -> void:
	radio_music.play(0.0)
	playing_timer.start(float(random_duration(play_min, play_max)))

func random_duration(min : int, max : int):
	var duration = randi_range(min, max) 
	print(duration)
	return duration
