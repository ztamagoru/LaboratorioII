extends EnemyState

func update(delta):
	if enemy._is_stopped:
		enemy._is_stopped = false
		enemy.death_timer = 0.0
		get_parent().change_state("Moving")
		return
	
	enemy.death_timer += delta
	
	if enemy.death_timer >= enemy.death_duration:
		get_tree().change_scene_to_file("res://scenes/menu/start_menu.tscn")
