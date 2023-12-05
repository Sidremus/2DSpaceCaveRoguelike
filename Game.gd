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

# Difficulty
var difficulty: float = 1.

# Game
var player: ACTOR
var cave_generator: CAVEGENERATOR
var mouse_pos:= Vector2.ZERO
var mouse_global_pos:= Vector2.ZERO
var input_vec:= Vector2.ZERO
var zoom: float = 1.

# Items
var item_container: Node
var flare_scene = preload("res://scenes/flare.tscn")
var flare_inst

# Cave Generator
var cave_size:= Vector2i(128, 128)
var noise_threshold: float = .05
var cave_noise: FastNoiseLite

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	item_container = Node.new()
	get_tree().get_root().add_child.call_deferred(item_container)
	randomize()
	player = get_tree().get_first_node_in_group("PLAYER")
	player.is_player_controlled = true
	cave_generator = get_tree().get_first_node_in_group("CAVEGENERATOR")
	cave_generator.generate()
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
	if Input.is_action_just_pressed("lmb"):
		cave_generator.clear_circle(mouse_global_pos, 75.)
	if Input.is_action_just_pressed("mmb"):
		zoom = 1.
	if Input.is_action_just_pressed("rmb"):
		player.is_drilling = true
	if Input.is_action_just_released("rmb"):
		player.is_drilling = false
	if Input.is_action_just_pressed("flare"): 
		if player:
			if flare_inst != null:
				flare_inst.flare_lifetime_max = 3.
				flare_inst.flare_lifetime = flare_inst.flare_lifetime_max / 2.
			flare_inst = flare_scene.instantiate() as ITEM
			flare_inst.global_rotation = player.global_rotation
			flare_inst.global_position = player.global_position
			flare_inst.linear_velocity = Vector2.RIGHT.rotated(player.global_rotation) * 550 #+ player.linear_velocity
			flare_inst.add_collision_exception_with(player)
			item_container.add_child(flare_inst)
			flare_inst.activate()
	if event.is_action_pressed("reload"):
		_ready()

func _process(_delta: float) -> void:
	input_vec.y = Input.get_axis("a", "d")
	input_vec.x = Input.get_axis("s", "w")
	if input_vec.length() > 1.: input_vec = input_vec.normalized()
