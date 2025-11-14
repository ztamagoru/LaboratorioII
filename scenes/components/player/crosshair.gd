extends CanvasLayer

@export var normal_color: Color = Color(1, 1, 1, 0.5)
@export var interact_color: Color = Color(0.255, 0.642, 0.328, 1.0)
@export var circle_radius: float = 15.0
@export var circle_thickness: float = 2.0

var current_color: Color
var crosshair_control: Control

func _ready():
	crosshair_control = Control.new()
	crosshair_control.set_anchors_preset(Control.PRESET_CENTER)
	crosshair_control.custom_minimum_size = Vector2(circle_radius * 3, circle_radius * 3)
	crosshair_control.position = -crosshair_control.custom_minimum_size / 2
	
	crosshair_control.draw.connect(_draw_crosshair)
	
	var center_container = get_node_or_null("Crosshair/CenterContainer")
	if center_container:
		center_container.add_child(crosshair_control)
	else:
		add_child(crosshair_control)
	
	set_normal()

func _draw_crosshair():
	var center = crosshair_control.size / 2
	
	crosshair_control.draw_arc(center, circle_radius, 0, TAU, 32, current_color, circle_thickness, true)

func set_normal():
	current_color = normal_color
	if crosshair_control:
		crosshair_control.queue_redraw()

func set_interactive():
	current_color = interact_color
	if crosshair_control:
		crosshair_control.queue_redraw()
