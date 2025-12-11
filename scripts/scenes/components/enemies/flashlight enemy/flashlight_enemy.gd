extends PathFollow3D

const speed : float = 2.5
const stop_distance : float = 0.05

var stop_points : Array[Marker3D] = []

var _is_stopped : bool = false
#var _is_attacking : bool = false

var death_timer : float = 0.0
const death_duration : float = 7.5

@onready var cd_timer : Timer = $WaitTimer
@onready var stop_sfx : AudioStreamPlayer3D = $StopSFX
@onready var walk_sfx : AudioStreamPlayer3D = $WalkSFX

const Rarity = {
	"COMMON": 0.75
	, "UNCOMMON": 0.25
}

var dict = {
	"continue": Rarity.COMMON
	, "stop": Rarity.UNCOMMON
}

func _ready():
	for child in $"../StopPoints".get_children():
		if child is Marker3D:
			stop_points.append(child)
	
	Globales.player.flash_area.scare_enemy.connect(continue_path)
	loop = true
	

func _process(delta: float) -> void:
	if !_is_stopped:
		return
	
	death_timer += delta
	
	if death_timer >= death_duration:
		get_tree().change_scene_to_file("res://scenes/menu/start_menu.tscn")
	

func _physics_process(delta : float):
	if _is_stopped:
		return
	
	progress += speed * delta
	
	for point in stop_points:
		var distance = global_position.distance_to(point.global_position) 
		
		if distance <= stop_distance:
			if cd_timer.time_left > 0:
				continue
			
			var stopping : bool = weighted_randomness()
			
			if stopping:
				stop_sfx.play(0)
				#_is_attacking = true
				_is_stopped = true
			break

func continue_path():
	if _is_stopped:
		_is_stopped = false
		#_is_attacking = false
		death_timer = 0.0
		walk_sfx.play(0)
	
	cd_timer.start(3.0)

func weighted_randomness():
	var key : String = WeightedChoice.pick(dict)
	print(key)
	return true if key == "stop" else false

func _on_walk_sfx_finished() -> void:
	if not _is_stopped:
		walk_sfx.play(0)
