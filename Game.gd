extends Node

# UI & Accessibility
var ui_alpha: float = .6
var camere_shake_intensity: float = 1.

# Controls
var wheel_tickrate:float = .25
var mouse_sensitivity: float = .01

# Difficulty
var difficulty: float = 1.

func _ready() -> void:
	randomize()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): get_tree().quit()
