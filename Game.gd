extends Node

# Settings
var ui_alpha: float = .6
var camere_shake_intensity: float = 1.
var wheel_tickrate:float = .25
var zoom_min:float = .25
var zoom_max:float = 4.
var mouse_sensitivity: float = .01
var is_control_actor_relative: bool = true
var camera_mouse_follow: bool = true

# Cave Generator
var skip_cave_generation: bool = false
var cave_size_int: int = 128
var cave_size:= Vector2i(cave_size_int, cave_size_int)
var noise_threshold: float = -.15
var cave_noise: FastNoiseLite

# Difficulty
var difficulty: float = 1.

# Game
var player: SHIP
var cave_generator: CAVEGENERATOR
var mouse_pos:= Vector2.ZERO
var mouse_global_pos:= Vector2.ZERO
var input_vec:= Vector2.ZERO
var zoom: float = 1.
var last_phys_delta: float

# Items
var item_container: Node
# Flare
var flare_scene = preload("res://scenes/flare.tscn")
var flare_inst: PROJECTILE
# Blaster
var blaster_shot_scene = preload("res://scenes/blaster_shot.tscn")
var time_since_last_shot: float = 5000.
var shots_per_second: float = 14.2
var max_blaster_gimbal_angle: float = 50.

# VFX
var blaster_shot_impact_PS: GPUParticles2D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	randomize()
	
	item_container = Node.new()
	get_tree().get_root().add_child.call_deferred(item_container)
	
	player = get_tree().get_first_node_in_group("PLAYER")
	player.is_player_controlled = true
	
	blaster_shot_impact_PS = get_tree().get_first_node_in_group("BLASTER_SHOT_IMPACT_PS")
	blaster_shot_impact_PS.set_amount(128)
	#blaster_shot_impact_PS.set_emitting(false) 
	
	cave_generator = get_tree().get_first_node_in_group("CAVEGENERATOR")
	if !skip_cave_generation: cave_generator.generate()
	cave_generator.clear_circle(player.global_position, 400)
	cave_noise = cave_generator.noise

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		mouse_pos = event.position
	if event.is_action_pressed("zoom_out"):
		zoom = maxf(zoom - wheel_tickrate, zoom_min)
	if event.is_action_pressed("zoom_in"):
		zoom = minf(zoom + wheel_tickrate, zoom_max)
	if Input.is_action_just_pressed("lmb"): pass
	if Input.is_action_just_pressed("mmb"):
		zoom = 1.
	if Input.is_action_just_pressed("rmb"):
		cave_generator.clear_circle(mouse_global_pos, 75.)
		player.is_drilling = true
	if Input.is_action_just_released("rmb"):
		player.is_drilling = false
	if Input.is_action_just_pressed("flare"): 
		if player: shoot_flare()
	if event.is_action_pressed("reload"):
		_ready()

func shoot_blaster():
	if time_since_last_shot > 1./shots_per_second:
		time_since_last_shot = 0.
		var blaster_shot_inst: PROJECTILE = blaster_shot_scene.instantiate()
		blaster_shot_inst.global_rotation = player.global_rotation + deg_to_rad(randf_range(-2.,2.)) + deg_to_rad(clampf(rad_to_deg(player.get_angle_to(mouse_global_pos)), -max_blaster_gimbal_angle, max_blaster_gimbal_angle))
		blaster_shot_inst.global_position = player.global_position
		blaster_shot_inst.linear_velocity = blaster_shot_inst.transform.x * blaster_shot_inst.speed #+ player.linear_velocity
		blaster_shot_inst.add_collision_exception_with(player)
		item_container.add_child(blaster_shot_inst)
		blaster_shot_inst.activate()

func shoot_flare():
	if flare_inst != null:
		flare_inst.lifetime_max = 3.
		flare_inst.lifetime = flare_inst.lifetime_max / 2.
	flare_inst = flare_scene.instantiate()
	flare_inst.global_rotation = player.global_rotation + player.get_angle_to(mouse_global_pos)
	flare_inst.global_position = player.global_position
	flare_inst.linear_velocity = flare_inst.transform.x * flare_inst.speed + player.linear_velocity
	flare_inst.add_collision_exception_with(player)
	item_container.add_child(flare_inst)
	flare_inst.activate()

func _process(delta: float) -> void:
	input_vec.y = Input.get_axis("a", "d")
	input_vec.x = Input.get_axis("s", "w")
	if input_vec.x > 0: input_vec.x *= 1.5
	#if input_vec.length() > 1.: input_vec = input_vec.normalized()
	input_vec = input_vec.limit_length(1.25)
	
	time_since_last_shot+= delta
	if Input.is_action_pressed("lmb"): shoot_blaster()

func _physics_process(delta: float) -> void:
	last_phys_delta = delta

func emit_particle(type: PROJECTILE.PROJECTILE_TYPE, position):
	if type == PROJECTILE.PROJECTILE_TYPE.BLASTER_SHOT:
		#blaster_shot_impact_PS.global_position = mouse_global_pos
		blaster_shot_impact_PS.emit_particle(
			blaster_shot_impact_PS.global_transform.translated(position - blaster_shot_impact_PS.global_position),
			Vector2.ZERO, Color.WHITE, Color.WHITE, 1)
