extends TileMap
class_name CAVEGENERATOR

@export var noise: FastNoiseLite

func generate():
	var starting_time: float = Time.get_unix_time_from_system()
	position = -Game.cave_size/2 * tile_set.tile_size.x
	noise.seed = randi_range(-50000,50000)
	clear()
	#for x in Game.cave_size.x:
		#for y in Game.cave_size.y:
			#set_cells_terrain_connect(0, get_surrounding_cells(cell), 0, 0, false)
	var cell_type: int = 0
	for x in Game.cave_size.x:
		for y in Game.cave_size.y:
			if x == 0 || x == Game.cave_size.y -1: cell_type = 0
			elif y == 0 || y == Game.cave_size.y -1: cell_type = 0
			elif noise.get_noise_2d(x,y) > Game.noise_threshold: cell_type = 0
			else: cell_type = -1
			set_cell(0, Vector2i(x,y), 0, Vector2i(cell_type,cell_type))
			#BetterTerrain.update_terrain_cell(self, 0, Vector2i(x,y), true)
			#print(str(i) + " | " + str(Game.cave_size.x * Game.cave_size.y))
	var t: String = "Map generation time: " + str(snapped(Time.get_unix_time_from_system() - starting_time, .1)) + " seconds"
	print_debug(t)
	
	var i: int = 0
	var size: int = get_used_cells(0).size()
	
	for cell in get_used_cells(0):
		BetterTerrain.update_terrain_cell(self, 0, cell, false)
		i += 1
		if  fmod(i, (size as float) / 10.) == 0.:
			t = str(snapped(((i as float) /(size as float)) * 100., 1)) + "% Autotiling: "
			t+= str(snapped(Time.get_unix_time_from_system() - starting_time, .1)) + "s since start, now at: " + str(i)+ " | " + str(size)
			print(t)
	print_debug("\n\nDone autotiling \nIt took " + str(snapped(Time.get_unix_time_from_system() - starting_time, .1)) + " seconds")
	#BetterTerrain.update_terrain_cells(self, 0, get_used_cells(0))
	#set_cells_terrain_connect(0, get_used_cells(0), 0, true)

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
			var neighbors: Array[Vector2i] = get_surrounding_cells(Vector2i(x,y))
			for neighbor in neighbors:
				set_cell(0, neighbor, 0, get_cell_atlas_coords(0, neighbor))
	for x in range(min_coord.x, max_coord.x):
		for y in range(min_coord.y, max_coord.y):
			BetterTerrain.update_terrain_cell(self, 0, Vector2i(x,y), true)
	redraw()

func fill_circle(circle_pos: Vector2, radius: float):
	var cell_global_pos:= Vector2.ZERO
	var cell_type: int = 0
	var min_coord: Vector2i = local_to_map(to_local(circle_pos - Vector2(radius, radius)))
	var max_coord: Vector2i = local_to_map(to_local(circle_pos + Vector2(radius, radius)))
	for x in range(min_coord.x, max_coord.x):
		for y in range(min_coord.y, max_coord.y):
			cell_global_pos = to_global(map_to_local(Vector2i(x,y)))
			cell_type = 0
			if cell_global_pos.distance_to(circle_pos) <= radius:
				set_cell(0, Vector2i(x,y), 0, Vector2i(cell_type,cell_type))
	for x in range(min_coord.x, max_coord.x):
		for y in range(min_coord.y, max_coord.y):
			BetterTerrain.update_terrain_cell(self, 0, Vector2i(x,y), true)
	redraw()

func clear_cell_at_position(pos: Vector2):
	var coord: Vector2i = local_to_map(to_local(pos))
	var edge_case:= coord.x <= 0 || coord.x + 1 >= Game.cave_size.x || coord.y <= 0 || coord.y + 1 >= Game.cave_size.y
	if !edge_case:
		set_cell(0, coord, 0, Vector2i(-1,-1))
		BetterTerrain.update_terrain_cell(self, 0, coord, true)
	redraw()

func redraw():
	visible = false
	#set_deferred("visible", false)
	set_deferred("visible", true)
