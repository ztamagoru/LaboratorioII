extends Control

@export_file("*.tscn") var level : String

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(level)
