extends Camera2D

func _process(delta: float) -> void:
	offset = get_tree().root.size / 2
	zoom = zoom.slerp(Vector2(Game.zoom, Game.zoom), 3. * delta)
	var mouse_dependent_offset = ((Game.mouse_pos - offset) / zoom) / 2.
	if Game.player:
		global_position = Game.player.global_position - offset + mouse_dependent_offset + Game.player.linear_velocity
		#rotation = Game.player.rotation + PI /2
	Game.mouse_global_pos = get_screen_center_position() + (Game.mouse_pos - offset)*.5
	#Game.mouse_global_pos = get_target_position()
	
