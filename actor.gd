extends RigidBody2D
class_name ACTOR

@export var speed: float = 1500.
@export var acceleration: float = 2000.
@export var rot_speed: float = 50.
@export var rot_acceleration: float = 10.

var is_player_controlled: bool = false
var is_drilling: bool = false
var move_target_pos:= Vector2.ZERO
var look_target_pos:= Vector2.ZERO
var target: ACTOR

func _physics_process(delta: float) -> void:
	if is_player_controlled:
		var target_vel:= Game.input_vec * speed
		if Game.is_control_actor_relative: target_vel = target_vel.rotated(rotation)
		else: target_vel = target_vel.rotated(-PI/2.)
		#var acc_fac = (linear_velocity - target_vel).length() / speed
		var acc_fac = target_vel.distance_to(linear_velocity) / speed
		acc_fac = remap(acc_fac ** 2, 0., 2., 1., 2.)
		linear_velocity = linear_velocity.move_toward(target_vel, acceleration * acc_fac * delta * Game.input_vec.length())
		
		angular_velocity = move_toward(angular_velocity, rot_speed * (get_angle_to(global_position + Game.mouse_pos - get_viewport_rect().size/2) / PI), rot_acceleration * delta)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if !is_drilling: return
	var contacts: int = get_contact_count()
	if contacts > 0:
		for contact in contacts:
			if state.get_contact_collider_object(contact) is CAVEGENERATOR:
				var impact_point: Vector2 = state.get_contact_local_position(contact)# + global_position
				impact_point = Game.cave_generator.to_local(impact_point)
				impact_point = Game.cave_generator.local_to_map(impact_point)
				var cond:= impact_point.x <= 0 || impact_point.x + 1 >= Game.cave_size.x || impact_point.y <= 0 || impact_point.y + 1 >= Game.cave_size.y
				if !cond: Game.cave_generator.set_cell(0, impact_point, 0, Vector2i(-1,-1))
