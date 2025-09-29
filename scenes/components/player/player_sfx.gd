extends Node3D

@onready var player : CharacterBody3D = get_parent()

@export var breathing_sfx : AudioStreamPlayer3D

func _process( delta: float):
	if player.stamina <= 0 and !breathing_sfx.playing:
		breathing_sfx.play(0.0)
