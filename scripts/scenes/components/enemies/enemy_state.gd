extends Node3D
class_name EnemyState

var enemy : Node3D

func _ready():
	enemy = get_parent().enemy

func enter():
	pass

func update(_delta):
	pass

func physics_update(_delta):
	pass

func exit():
	pass
