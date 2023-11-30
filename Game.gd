extends Node

# Settings
var ui_alpha: float = .6
var camere_shake_intensity: float = 1.
var wheel_tickrate:float = .25
var zoom_min:float = .25
var zoom_max:float = 4.
var mouse_sensitivity: float = .01
var is_control_actor_relative: bool = true

# Difficulty
var difficulty: float = 1.

# Game
var player: ACTOR
var cave_generator: CAVEGENERATOR
var mouse_pos:= Vector2.ZERO
var mouse_global_pos:= Vector2.ZERO
var input_vec:= Vector2.ZERO
var zoom: float = 1.
var cave_size:= Vector2i(512, 512)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	randomize()
	player = get_tree().get_first_node_in_group("PLAYER")
	player.is_player_controlled = true
	cave_generator = get_tree().get_first_node_in_group("CAVEGENERATOR")
	cave_generator.generate()
	cave_generator.clear_circle(player.global_position, 400)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): get_tree().quit()
	if event is InputEventMouseMotion: mouse_pos = event.position
	if event.is_action_pressed("zoom_out"): zoom = maxf(zoom - wheel_tickrate, zoom_min)
	if event.is_action_pressed("zoom_in"):  zoom = minf(zoom + wheel_tickrate, zoom_max)
	if Input.is_action_just_pressed("lmb"): cut_hole_at_mouse_pos()
	if Input.is_action_just_pressed("rmb"): player.is_drilling = true
	if Input.is_action_just_released("rmb"): player.is_drilling = false
	if event.is_action_pressed("reload"): _ready()

func cut_hole_at_mouse_pos():
	cave_generator.clear_circle(mouse_global_pos, 75.)

func _process(_delta: float) -> void:
	input_vec.y = Input.get_axis("a", "d")
	input_vec.x = Input.get_axis("s", "w")
	input_vec = input_vec.limit_length(1.)
