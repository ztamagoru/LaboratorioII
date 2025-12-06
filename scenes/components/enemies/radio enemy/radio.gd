extends RigidBody3D

@export var radio_music : AudioStreamPlayer3D
@export var pause_timer : Timer
@export var playing_timer : Timer

@export var chair_area : Area3D

# Configuración de eventos de distorsión
@export_group("Distortion Settings")
@export var min_time_between_distortions: float = 10.0  # Tiempo mínimo entre distorsiones
@export var max_time_between_distortions: float = 30.0  # Tiempo máximo entre distorsiones
@export var distortion_duration: float = 10.0  # Duración de la distorsión

# Variables para el sistema de distorsión
var is_distorting: bool = false
var is_player_seated: bool = false
var distortion_timer: float = 0.0
var next_distortion_timer: float = 0.0
var original_pitch: float = 1.0
var player_reference: CharacterBody3D = null

func _ready():
	if radio_music:
		original_pitch = radio_music.pitch_scale
		radio_music.play(0.0)

	# Programar el primer evento de distorsión
	schedule_next_distortion()

	if chair_area:
		chair_area.player_sat_down.connect(_on_player_sat_down)
		chair_area.player_stood_up.connect(_on_player_stood_up)

func _process(delta):
	# Contador para el próximo evento de distorsión
	if not is_distorting and next_distortion_timer > 0:
		next_distortion_timer -= delta
		if next_distortion_timer <= 0:
			start_distortion()
	else:
		distortion_timer += delta
		var progress = distortion_timer / distortion_duration

		apply_distortion(progress)

		if distortion_timer >= distortion_duration:
			end_distortion()

func schedule_next_distortion():
	next_distortion_timer = randf_range(min_time_between_distortions, max_time_between_distortions)
	print("Próxima distorsión en: %.1f segundos" % next_distortion_timer)

func start_distortion():
	is_distorting = true
	distortion_timer = 0.0
	print("¡ALERTA! La radio comienza a distorsionarse...")
	print("¡Corre a sentarte en la silla antes de que sea tarde!")
	print("Tienes %.0f segundos..." % distortion_duration)

func apply_distortion(progress: float):
	if not radio_music:
		return

	# Distorsión de pitch (fluctúa de manera errática)
	var pitch_variation = sin(progress * PI * 6.0) * 0.4 * progress
	radio_music.pitch_scale = original_pitch + pitch_variation - (progress * 0.3)

	# Reducir volumen gradualmente hasta silencio total
	var volume_db = lerp(0.0, -80.0, progress)
	radio_music.volume_db = volume_db

	# Efecto de "corte" aleatorio cuando está muy distorsionado
	if progress > 0.6 and randf() < 0.15:
		radio_music.volume_db = -80.0
		await get_tree().create_timer(0.05).timeout
		if is_distorting:  # Verificar que aún está en distorsión
			radio_music.volume_db = lerp(0.0, -80.0, progress)

func end_distortion():
	is_distorting = false
	distortion_timer = 0.0

	if radio_music:
		radio_music.stop()

	print("La música se detuvo")

	# Verificar si el jugador está sentado
	if is_player_seated:
		# El jugador sobrevive
		print("¡SOBREVIVISTE!")
		await get_tree().create_timer(1.0).timeout
		restore_audio()
		schedule_next_distortion()
	else:
		# El jugador muere
		print("¡NO ESTABAS SENTADO! GAME OVER")
		await get_tree().create_timer(0.5).timeout
		kill_player()

func restore_audio():
	if radio_music:
		# Restaurar configuración original
		radio_music.pitch_scale = original_pitch
		radio_music.volume_db = 0.0
		# Reiniciar la música
		radio_music.play(0.0)
		print("La música vuelve a la normalidad")

func kill_player():
	print(" === GAME OVER ===")
	
	# Desactivar físicas del jugador
	if player_reference:
		player_reference.set_physics_process(false)
		# Si tienes un script de movimiento, desactívalo
		if player_reference.has_method("disable_movement"):
			player_reference.disable_movement()
	
	# Mostrar Game Over
	show_game_over()

func show_game_over():
	# Implementar pantalla de Game Over
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/menu/start_menu.tscn")

# Funciones para detectar si el jugador está sentado
func _on_player_sat_down():
	is_player_seated = true
	print("Jugador sentado en la silla (a salvo)")

func _on_player_stood_up():
	if not is_distorting:
		is_player_seated = false
		print("Jugador se levantó de la silla")
	else:
		print("No puedes levantarte durante la distorsión!")
