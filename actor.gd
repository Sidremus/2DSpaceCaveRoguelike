extends RigidBody2D
class_name ACTOR

# -- Movement --
var is_drilling: bool = false
var target: ACTOR
var target_rot: float
var last_phys_delta: float
@export var speed: float = 250.
@export var acceleration: float = 450.
@export var rot_speed: float = 2.5

# -- AI --
var is_player_controlled: bool = false
var move_target_pos:= Vector2.ZERO
var look_target_pos:= Vector2.ZERO

func _physics_process(delta: float) -> void:
	last_phys_delta = delta
	if is_player_controlled:
		var target_vel:= Game.input_vec * speed
		if Game.is_control_actor_relative: target_vel = target_vel.rotated(rotation)
		else: target_vel = target_vel.rotated(-PI/2.)
		var acc_fac = target_vel.distance_to(linear_velocity) / speed
		acc_fac = remap(acc_fac ** 2, 0., 2., 1., 2.)
		linear_velocity = linear_velocity.move_toward(target_vel, acceleration * acc_fac * delta * Game.input_vec.length())

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_player_controlled:
		target_rot = get_angle_to(Game.mouse_global_pos)
		rotation = rotate_toward(rotation, rotation + target_rot, rot_speed * last_phys_delta)
	
	if is_drilling:
		var contacts: int = get_contact_count()
		if contacts > 0:
			for contact in contacts:
				if state.get_contact_collider_object(contact) is CAVEGENERATOR:
					state.get_contact_collider_object(contact).clear_cell_at_position(state.get_contact_local_position(contact))
