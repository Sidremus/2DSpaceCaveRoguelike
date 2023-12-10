extends Line2D
var target: SHIP
var ref_pos: Vector2
var offset: Vector2
var trail_length: int = 63
var trail_points: PackedVector2Array
var max_measured_speed:float = 1.

func _ready() -> void:
	target = get_parent()
	ref_pos = target.global_position
	clear_points()
	call_deferred("set_as_top_level", true)

func _physics_process(delta: float) -> void:
	add_point(to_local(target.global_position + position.rotated(target.global_rotation)), 1)
	ref_pos = target.global_position
	offset = offset.move_toward(Game.input_vec.rotated(target.global_rotation) * delta * target.speed, max(delta, Game.input_vec.length())) 
	for i in points.size():
		if i == 0:
			set_point_position(0, to_local(target.global_position + position.rotated(target.global_rotation)))
		else:
			var fac: float = 1.-((i as float)/ (points.size() as float))
			var new_pos: Vector2 = to_global(points[i]) 
			new_pos -= fac * target.linear_velocity * 2. * delta
			new_pos -= offset * (fac ** 2.) * (target.linear_velocity.length() / max_measured_speed)
			new_pos = to_local(new_pos)
			set_point_position(i, new_pos)
	max_measured_speed = max(max_measured_speed, target.linear_velocity.length())
	modulate = modulate.lerp(Color(modulate, (target.linear_velocity.length() / max_measured_speed)), delta)
	while points.size() > trail_length: remove_point(trail_length)
