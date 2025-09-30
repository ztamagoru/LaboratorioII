extends Control

@export var stamina_bar : ProgressBar
@onready var _to_fade_cd : Timer = $ToFadeTimer

var _fade_tween : Tween
var _fading : bool = false
var _faded : bool = false

const fade_cd : float = 1.0
const fade_duration : float = 1.5

func _ready():
	await get_tree().process_frame
	stamina_bar.max_value = Globals.player.max_stamina

func _process(delta : float):
	var current_value : float = Globals.player.stamina
	
	stamina_bar.value = current_value
	
	if current_value == Globals.player.max_stamina:
		if not _fading and not _faded and _to_fade_cd.is_stopped():
				_to_fade_cd.start(fade_cd)
	
	else:
		if _fading or _faded or self.modulate.a < 1.0:
			_reset_fade()

func _reset_fade():
	if _fade_tween:
		_fade_tween.kill()
	
	self.modulate.a = 1.0
	_fading = false
	_faded = false
	_to_fade_cd.stop()

func _on_to_fade_timer_timeout() -> void:
	_fading = true
	_faded = false
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	_fade_tween.finished.connect(func():
		_fading = false
		_faded = true
		)
