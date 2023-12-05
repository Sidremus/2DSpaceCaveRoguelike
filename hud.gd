extends Control
class_name HUD
@onready var mouse_cursor: Sprite2D = $Mouse_Cursor
@onready var top_left_label: Label = $TopLeftText

func _process(_delta: float) -> void:
	if Game.player:
		mouse_cursor.position = Game.mouse_pos #+ Game.player.global_position - (get_tree().root.size as Vector2) / 2
	top_left_label.text = str(Engine.get_frames_per_second())
