extends RigidBody2D
class_name ACTOR

# -- Movement --
@export var speed: float = 450.
@export var acceleration: float = 150.
@export var rot_speed: float = 8.5
@export var rot_acceleration: float = 3.5
var target_rot: float
var target_vel: Vector2

var is_drilling: bool = false

# -- AI --
var target: ACTOR
var is_player_controlled: bool = false
var move_target_pos:= Vector2.ZERO
var look_target_pos:= Vector2.ZERO

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_player_controlled:
		var rot_acc_fac: float = 4. * (1-(abs(angular_velocity)/rot_speed))**4
		var new_target_torque: float = ((get_angle_to(Game.mouse_global_pos))/PI) * rot_speed
		target_rot = move_toward(angular_velocity, new_target_torque, rot_acceleration * rot_acc_fac * Game.last_phys_delta)
		angular_velocity = target_rot
		
		if Game.input_vec.length() != 0.:
			var new_target_vel:= Game.input_vec * speed
			if Game.is_control_actor_relative: new_target_vel = new_target_vel.rotated(rotation)
			else: new_target_vel = new_target_vel.rotated(-PI/2.)
			var acc_fac = new_target_vel.distance_to(linear_velocity) / speed
			acc_fac = remap(acc_fac ** 2, 0., 2., 1., 2.)
			linear_velocity = linear_velocity.move_toward(new_target_vel, acceleration * acc_fac * Game.last_phys_delta * Game.input_vec.length())
			target_vel = linear_velocity
		else:
			linear_velocity = target_vel
	
	if is_drilling:
		var contacts: int = get_contact_count()
		if contacts > 0:
			for contact in contacts:
				if state.get_contact_collider_object(contact) is CAVEGENERATOR:
					state.get_contact_collider_object(contact).clear_cell_at_position(state.get_contact_local_position(contact))

func _on_body_entered(_body: Node) -> void:
	set_deferred("target_vel", linear_velocity if !is_drilling else linear_velocity *.95)
