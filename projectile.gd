extends RigidBody2D
class_name PROJECTILE

enum PROJECTILE_TYPE {FLARE, BLASTER_SHOT}
@export var speed: float = 550.
@export var lifetime_max: float = 60.
@export var type: PROJECTILE_TYPE

var is_active: bool = false
var activation_time: float
var main_tween: Tween
var owning_actor: SHIP
var lifetime: float = 0.
var light: PointLight2D

@export_subgroup("FLARE")
var flare_color: Color
var flare_center_sprite: Sprite2D
var flare_center_sparkle: Sprite2D
var flare_center_sprite_scale: float
@export var flare_light_curve: Curve

func activate():
	if type == PROJECTILE_TYPE.FLARE:
		activation_time = Time.get_unix_time_from_system()
		lifetime = 0.
		main_tween = create_tween()
		main_tween.tween_callback(clear_all_collision_exceptions).set_delay(0.3)
		set_deferred("is_active", true)
	elif type == PROJECTILE_TYPE.BLASTER_SHOT:
		lifetime = 0.
		set_deferred("is_active", true)

func deactivate():
	if type == PROJECTILE_TYPE.FLARE:
		is_active = false
		queue_free()
	elif type == PROJECTILE_TYPE.BLASTER_SHOT:
		is_active = false
		linear_velocity = Vector2.ZERO
		set_collision_mask_value(1, false)
		set_deferred("freeze", true)
		$BlasterProjectileColored.hide()
		var fac: float = 1.5
		light.energy = 3.
		light.texture_scale = light.texture_scale * fac
		main_tween = create_tween()
		main_tween.set_parallel(true)
		main_tween.set_ease(Tween.EASE_OUT)
		main_tween.set_trans(Tween.TRANS_QUAD)
		main_tween.tween_property(light, "energy", 0., Game.blaster_shot_impact_PS.lifetime)
		main_tween.tween_property(light, "texture_scale", light.texture_scale * fac, Game.blaster_shot_impact_PS.lifetime)
		main_tween.set_parallel(false)
		main_tween.tween_callback(queue_free)

func _physics_process(delta: float) -> void:
	if is_active:
		lifetime += delta
		if type == PROJECTILE_TYPE.FLARE:
			var t: float = remap(Game.cave_noise.get_noise_1d(lifetime*30), -1., 1., .5, 1.5)
			var curve_value: float = flare_light_curve.sample(lifetime / lifetime_max)
			light.energy = curve_value * 3.
			light.color = Color(flare_color, t * curve_value)
			light.texture_scale = curve_value * 2.5
			flare_center_sparkle.rotate(randf() * PI * .5)
			flare_center_sparkle.scale = Vector2(flare_center_sprite_scale / 3., flare_center_sprite_scale / 3.) * t * (min(curve_value ** 2, .5) * 2.)
			flare_center_sprite.scale = Vector2(flare_center_sprite_scale, flare_center_sprite_scale) * t * (min(curve_value ** 2, .5) * 2.)
			if lifetime > lifetime_max: deactivate()
		if type == PROJECTILE_TYPE.BLASTER_SHOT:
			light.energy = clamp(min(lifetime * 4., 2.), 0., 2.)
			if lifetime > lifetime_max: deactivate()
	else:
		if type == PROJECTILE_TYPE.BLASTER_SHOT && linear_velocity != Vector2.ZERO: linear_velocity = Vector2.ZERO

func _ready() -> void:
	if type == PROJECTILE_TYPE.FLARE:
		light = $PointLight2D
		flare_center_sprite = $PointLight2D/Sparkle
		flare_center_sparkle = $PointLight2D/Sparkle2
		flare_center_sprite_scale = flare_center_sprite.scale.x
		flare_color = light.color
		flare_color.h += randf_range(-.025, .025)
		flare_color.s += randf_range(-.1, .1)
		activate()
	elif type == PROJECTILE_TYPE.BLASTER_SHOT:
		light = $PointLight2D
		light.energy = 0.
		activate()

func clear_all_collision_exceptions():
	for excepted_body in get_collision_exceptions():
		remove_collision_exception_with.call_deferred(excepted_body)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if type == PROJECTILE_TYPE.BLASTER_SHOT:
		if get_contact_count() > 0:
			Game.emit_particle(type, state.get_contact_local_position(0))
			if state.get_contact_collider_object(0) is CAVEGENERATOR: state.get_contact_collider_object(0).clear_cell_at_position(state.get_contact_local_position(0))
			global_position = state.get_contact_local_position(0)
			deactivate()
