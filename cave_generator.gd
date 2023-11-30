extends TileMap
class_name CAVEGENERATOR

@export var noise: FastNoiseLite
var threshold: float = -.2

func generate():
	position = -Game.cave_size/2 * tile_set.tile_size.x
	noise.seed = randi_range(-50000,50000)
	clear()
	var cell_type: int = 0
	for x in Game.cave_size.x:
		for y in Game.cave_size.y:
			if x == 0 || x == Game.cave_size.y -1: cell_type = 0
			elif y == 0 || y == Game.cave_size.y -1: cell_type = 0
			elif noise.get_noise_2d(x,y) > threshold: cell_type = 0
			else: cell_type = -1
			set_cell(0, Vector2i(x,y), 0, Vector2i(cell_type,cell_type))

func clear_circle(circle_pos: Vector2, radius: float):
	var cell_global_pos:= Vector2.ZERO
	var cell_type: int = 0
	var min_coord: Vector2i = local_to_map(to_local(circle_pos - Vector2(radius, radius)))
	var max_coord: Vector2i = local_to_map(to_local(circle_pos + Vector2(radius, radius)))
	for x in range(min_coord.x, max_coord.x):
		for y in range(min_coord.y, max_coord.y):
			cell_global_pos = to_global(map_to_local(Vector2i(x,y)))
			if x == 0 || x == Game.cave_size.y -1: cell_type = 0
			elif y == 0 || y == Game.cave_size.y -1: cell_type = 0
			else: cell_type = -1
			if cell_global_pos.distance_to(circle_pos) <= radius:
				set_cell(0, Vector2i(x,y), 0, Vector2i(cell_type,cell_type))
