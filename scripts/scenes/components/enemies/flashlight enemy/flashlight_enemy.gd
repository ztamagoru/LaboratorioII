extends PathFollow3D

const speed : float = 5.0
const stop_time : float = 2.5
const stop_distance : float = 0.05

var stop_points : Array[Marker3D] = []

var stop_timer : float = 0.0
var _is_stopped : bool = false

func _ready():
	for child in $"../StopPoints".get_children():
		if child is Marker3D:
			stop_points.append(child)
	
	#await get_tree().process_frame`
	
	Globals.player.flash_area.scare_enemy.connect(continue_path)
	loop = true

func _physics_process(delta : float):
	if _is_stopped:
		#stop_timer -= delta
		#
		#if stop_timer <= 0:
			#_is_stopped = false
		return
	
	progress += speed * delta
	
	for point in stop_points:
		var distance = global_position.distance_to(point.global_position) 
		
		if distance <= stop_distance:
			_is_stopped = true
			#stop_timer = stop_time
			break

func continue_path():
	print("resuming path")
	
	_is_stopped = false
