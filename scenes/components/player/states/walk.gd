extends State

func enter():
	print(name)

func update(_delta):
	pass

func physics_update(_delta):
	if not player.is_on_floor():
		get_parent().change_state("Fall")
		return
	
	if Input.is_action_just_pressed("move_jump"):
		get_parent().change_state("Jump")
		return
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		player.velocity.x = direction.x * player.current_speed
		player.velocity.z = direction.z * player.current_speed
		player.move_and_slide()
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.current_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.current_speed)
		
		get_parent().change_state("Idle")
		return

func exit():
	pass
