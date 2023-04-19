extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func calculate_min_moves(tile_colors, all_colors):
	var min_moves := 0
	while !tile_colors == all_colors:
		for index in tile_colors.size():
			if !tile_colors[index] == all_colors[index]:
				var color_index = all_colors.find(tile_colors[index])
				if tile_colors[color_index] == all_colors[index] and index < color_index:
					var temp = tile_colors[index]
					tile_colors[index] = tile_colors[color_index]
					tile_colors[color_index] = temp
					min_moves += 1
		for index in tile_colors.size():
			if !tile_colors[index] == all_colors[index]:
				var color_index = all_colors.find(tile_colors[index])
				var temp = tile_colors[index]
				tile_colors[index] = tile_colors[color_index]
				tile_colors[color_index] = temp
				min_moves += 1
	print(tile_colors == all_colors)
	print(min_moves)
	return min_moves
				
	

func fix_corners(rows, lines):
	 return [0,lines-1,lines*rows-lines,lines*rows-1]
	
func fix_sides_no_corners(rows, lines):
	var tiles := []
	for i in lines:
		i+=1
		if i <= lines-2:
			tiles.append(i)
	for i in rows:
		i += lines + (lines-1)*(i)
		if i < rows*lines-lines:
			tiles.append(i)
	for i in rows:
		i = (lines-1) + lines*(i+1)
		if i < rows*lines-1:
			tiles.append(i)
	for i in lines:
		i = rows * lines -lines +i+1
		if i < rows*lines-1:
			tiles.append(i)
	return tiles
	
func fix_center(rows,lines):
	var center = (float(lines)/2) + lines * (rows/2)
	var tiles = [center, center + 1, center -1, center -lines-1, center -lines, center -lines+1,center +lines-1, center +lines, center +lines+1]
	return tiles
