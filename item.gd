extends RigidBody2D
class_name ITEM

enum ITEM_TYPE {FLARE, WEAPON, PICKUP}
@export var type: ITEM_TYPE

var is_active: bool = false
var activation_time: float
var main_tween: Tween
var owning_actor: ACTOR

@export_subgroup("Flare")
var flare_lifetime_max: float = 60.
var flare_lifetime: float = 0.
var flare_light: PointLight2D
var flare_color: Color
var flare_center_sprite: Sprite2D
var flare_center_sparkle: Sprite2D
var flare_center_sprite_scale: float
@export var flare_light_curve: Curve

func activate():
	if type == ITEM_TYPE.FLARE:
		activation_time = Time.get_unix_time_from_system()
		flare_lifetime = 0.
		main_tween = create_tween()
		main_tween.tween_callback(clear_all_collision_exceptions).set_delay(0.3)
		set_deferred("is_active", true)

func deactivate():
	if type == ITEM_TYPE.FLARE:
		is_active = false
		flare_light.hide()
		queue_free()

func _physics_process(delta: float) -> void:
	if is_active:
		if type == ITEM_TYPE.FLARE:
			flare_lifetime += delta
			var t: float = remap(Game.cave_noise.get_noise_1d(flare_lifetime*30), -1., 1., .5, 1.5)
			var curve_value: float = flare_light_curve.sample(flare_lifetime / flare_lifetime_max)
			flare_light.energy = curve_value * 3.
			flare_light.color = Color(flare_color, t * curve_value)
			flare_light.texture_scale = curve_value * 2.5
			flare_center_sparkle.rotate(randf() * PI * .5)
			flare_center_sparkle.scale = Vector2(flare_center_sprite_scale / 3., flare_center_sprite_scale / 3.) * t * (min(curve_value ** 2, .5) * 2.)
			flare_center_sprite.scale = Vector2(flare_center_sprite_scale, flare_center_sprite_scale) * t * (min(curve_value ** 2, .5) * 2.)
			if flare_lifetime > flare_lifetime_max: deactivate()

func _ready() -> void:
	if type == ITEM_TYPE.FLARE:
		flare_light = $PointLight2D
		flare_center_sprite = $PointLight2D/Sparkle
		flare_center_sparkle = $PointLight2D/Sparkle2
		flare_center_sprite_scale = flare_center_sprite.scale.x
		flare_color = flare_light.color
		flare_color.h += randf_range(-.025, .025)
		flare_color.s += randf_range(-.1, .1)
		activate()

func clear_all_collision_exceptions():
	for excepted_body in get_collision_exceptions():
		remove_collision_exception_with.call_deferred(excepted_body)
