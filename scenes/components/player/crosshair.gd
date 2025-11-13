extends CanvasLayer

@export var normal_color: Color = Color(1, 1, 1, 0.5)
@export var interact_color: Color = Color(0.964, 0.137, 0.521, 1.0)

@onready var horizontal = $Crosshair/CenterContainer/CrosshairShape/Horizontal
@onready var vertical = $Crosshair/CenterContainer/CrosshairShape/Vertical

func _ready():
	set_normal()

func set_normal():
	if horizontal and vertical:
		horizontal.color = normal_color
		vertical.color = normal_color

func set_interactive():
	if horizontal and vertical:
		horizontal.color = interact_color
		vertical.color = interact_color
