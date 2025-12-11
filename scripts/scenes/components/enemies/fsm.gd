extends Node3D
class_name EnemyStateMachine

@export var enemy : PathFollow3D

var current_state : EnemyState

func _ready():
	current_state = get_child(0)
	current_state.enter()

func _process(delta):
	current_state.update(delta)

func _physics_process(delta):
	current_state.physics_update(delta)

func change_state(next_state : String):
	current_state.exit()
	current_state = get_node(next_state)
	current_state.enter()
