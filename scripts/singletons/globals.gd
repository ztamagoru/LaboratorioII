extends Node

var player : CharacterBody3D

func _ready():
	#DisplayServer.window_set_size(Vector2i(1280,720))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	#var window_size = get_window().get_size_with_decorations()
	#get_window().set_position(screen_center - window_size / 2)

func _process(_delta : float):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
