extends Node3D
class_name State

var player : CharacterBody3D

func _ready():
	player = get_parent().player

func enter():
	pass

func update(_delta):
	pass

func physics_update(_delta):
	pass

func exit():
	pass
