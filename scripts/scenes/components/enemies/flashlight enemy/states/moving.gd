extends EnemyState

var moving : bool = false

func enter():
	moving = true
	
	await get_tree().process_frame
	enemy.walk_sfx.play(0)

func physics_update(delta):	
	enemy.progress += enemy.speed * delta
	
	for point in enemy.stop_points:
		var distance = enemy.global_position.distance_to(point.global_position) 
		
		if distance <= enemy.stop_distance:
			if enemy.cd_timer.time_left > 0:
				continue
			
			var stopping : bool = enemy.weighted_randomness()
			
			if stopping:
				enemy.stop_sfx.play(0)
				enemy._is_stopped = true
				get_parent().change_state("Idle")
				return

func exit():
	moving = false

func _on_walk_sfx_finished() -> void:
	if moving:
		enemy.walk_sfx.play(0)
