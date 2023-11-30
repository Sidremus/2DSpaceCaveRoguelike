extends Camera2D

func _process(_delta: float) -> void:
	offset = get_tree().root.size / 2
	zoom = Vector2(Game.zoom, Game.zoom)
	if Game.player: global_position = Game.player.global_position - offset
	Game.mouse_global_pos = to_global(Game.mouse_pos)
