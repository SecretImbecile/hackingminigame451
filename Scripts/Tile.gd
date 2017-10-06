extends Node2D

# class member variables go here, for example:
export(int) var tile_type
export(bool) var flow_connected = false
export(float) var flow_percent = 0



# converts flow percent to degrees for corner pieces
func percent2rad():
	return (flow_percent * PI) / 100



func _ready():
	set_fixed_process(true)
	set_process(true)



func _fixed_process(delta):
	flow_percent += 1
	flow_percent = fmod(flow_percent, 100)



func _process(delta):
	
	# Update the polygon, each tile type has its own function for this
	if tile_type <= 0:
		printerr("Tile: Incorrect tile type")
	elif tile_type == 1:
		draw_tile_horizontal()
	elif tile_type == 2:
		draw_tile_vertical()
	elif tile_type == 3:
		draw_tile_corner1()


### Horribly repetative code below


func draw_tile_horizontal():	
	if flow_connected:
		#calculate positions of moving vertices
		var vertex_top = Vector2(128 * (flow_percent / 100), 0)
		var vertex_bottom = Vector2(128 * (flow_percent / 100), 128)
		
		#set 'full' polygon
		var full = Vector2Array()
		full.resize(4)
		full.set(0, draw_tile_vertex(0))
		full.set(1, vertex_top)
		full.set(2, vertex_bottom)
		full.set(3, draw_tile_vertex(3))
		
		#set 'empty' polygon
		var empty = Vector2Array()
		empty.resize(4)
		empty.set(0, vertex_top)
		empty.set(1, draw_tile_vertex(1))
		empty.set(2, draw_tile_vertex(2))
		empty.set(3, vertex_bottom)
		
		#remove polygons with no area
		if flow_percent == 0:
			full.resize(0)
		elif flow_percent == 100:
			empty.resize(0)
#		
		get_node("full").set_polygon(full)
		get_node("empty").set_polygon(empty)



func draw_tile_vertical():
	if flow_connected:
		#calculate positions of moving vertices
		var vertex_left = Vector2(0, 128 * (flow_percent / 100))
		var vertex_right = Vector2(128, 128 * (flow_percent / 100))
		
		#set 'full' polygon
		var full = Vector2Array()
		full.resize(4)
		full.set(0, draw_tile_vertex(0))
		full.set(1, draw_tile_vertex(1))
		full.set(2, vertex_right)
		full.set(3, vertex_left)
		
		#set 'empty' polygon
		var empty = Vector2Array()
		empty.resize(4)
		empty.set(0, vertex_left)
		empty.set(1, vertex_right)
		empty.set(2, draw_tile_vertex(2))
		empty.set(3, draw_tile_vertex(3))
		
		#remove polygons with no area
		if flow_percent == 0:
			full.resize(0)
		elif flow_percent == 100:
			empty.resize(0)
		
		get_node("full").set_polygon(full)
		get_node("empty").set_polygon(empty)



func draw_tile_corner1():
	if flow_connected:
		# correct flow speed with a trigonometric function
		var trig = -128 * abs(sin(percent2rad() - (PI/2))) + 128
			
		# calculate positions of moving vertex
		var vertex_centre
		
		if flow_percent < 50:
			vertex_centre = Vector2(trig, 0)
		else:
			vertex_centre = Vector2(128, 128-trig)
		
		# set 'full' polygon
		var full = Vector2Array()
		full.resize(3)
		full.set(0, draw_tile_vertex(0))
		full.set(1, vertex_centre)
		full.set(2, draw_tile_vertex(3))
		
		# set 'empty' polygon
		var empty = Vector2Array()
		empty.resize(3)
		empty.set(0, draw_tile_vertex(3))
		empty.set(1, vertex_centre)
		empty.set(2, draw_tile_vertex(2))
		
		# extend one of the polygons
		if flow_percent < 50:
			empty.insert(1, vertex_centre)
			empty.set(2, draw_tile_vertex(1))
		elif flow_percent > 50:
			full.set(1, draw_tile_vertex(1))
			full.insert(2, vertex_centre)
		
		get_node("full").set_polygon(full)
		get_node("empty").set_polygon(empty)



# Returns the position of static vertices
func draw_tile_vertex(vertex):	
	if int(vertex) == 0:
		return Vector2(0, 0)
	elif int(vertex) == 1:
		return Vector2(128, 0)
	elif int(vertex) == 2:
		return Vector2(128, 128)
	elif int(vertex) == 3:
		return Vector2(0, 128)
	else:
		printerr("draw_tile_vertex: incorrect parameter")
		return Vector2(0, 0)