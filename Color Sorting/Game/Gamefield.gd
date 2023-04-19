extends Node2D

onready var color_tile = preload("res://Color Sorting/Game/ColorTiles.tscn")

onready var time_label = get_node("End_Game/End_Game_UI/CenterContainer/VBoxContainer/MarginContainer/MarginContainer/HBoxContainer/Stats/TimeStat")
onready var moves_label = get_node("End_Game/End_Game_UI/CenterContainer/VBoxContainer/MarginContainer/MarginContainer/HBoxContainer/Stats/MovesStat") 
onready var confetti = get_node("Particles2D")


var viewport_size

var line_tiles := 0
var row_tiles := 0
var custom_color1 := Color(1,1,1,1)
var custom_color2 := Color(0,0,0,1)
var tilesize := Vector2()
var current_z 


var easy = false
var moderate = false
var hard = false
var extrem = false
var custom = false
var help = false
var running = false

var time = 0
var time_on = false
var moves_done := 0
var min_moves := 0 

var all_tiles := [] #zuerst werden die Positionsvektoren hinzugefügt und danach die TileInstanzen
var all_colors := []

func _ready():
	randomize()
	viewport_size = get_viewport().size
	$End_Game/End_Game_UI.hide()
	$CustomUI/CustomUI.hide()
	$GUI/MarginContainer.hide()

	
func start_game():
	moves_done = 0
	time = 0
	time_on = true
	running = true
	$GUI/MarginContainer.show()
	if easy: 
		row_tiles = randi()% 2 + 5
		line_tiles = randi()% 2 + 5
	elif moderate: 
		row_tiles = randi()% 3 + 7
		line_tiles = randi()% 3 + 7
	elif hard: 
		row_tiles = randi()% 3 + 9
		line_tiles = randi()% 3 + 9
	elif extrem: 
		row_tiles = randi()% 3 + 11
		line_tiles = randi()% 3 + 11
	elif custom:
		pass
		
	prepare_grid()
	instance_colors()
	
func prepare_grid():
	var size = calculate_size()
	for i in row_tiles:
		var y_coord = (viewport_size.y/6 + size[1]/row_tiles * i)
		for j in line_tiles:
			var x_coord = (viewport_size.x/10 + size[0]/line_tiles * j)
			var tile_coord = Vector2(x_coord,y_coord)
			all_tiles.append([tile_coord])


func calculate_size():
	var x_line:float = float(viewport_size.x) - float(2*viewport_size.x/10)
	var y_line:float = float(viewport_size.y) - float(2*viewport_size.y/6)
	tilesize = Vector2(int(x_line/line_tiles) +1, int(y_line/row_tiles)+1)
	print(tilesize)
	return [x_line, y_line]
		
func prepare_colors():
	var color_flip = randi() %2 == 0
	var base_color
	var color_max
	if custom:
		base_color = [custom_color1.r,custom_color1.g,custom_color1.b]
		color_max = [custom_color2.r,custom_color2.g,custom_color2.b]
	else:
#		base_color = [rand_range(0,0.5),rand_range(0,0.5),rand_range(0,0.5)]
#		color_max = [base_color[0]+rand_range(0.2,0.5),base_color[1]+rand_range(0.2,0.5),base_color[2]+rand_range(0.2,0.5)]
		base_color = [rand_range(0.4,0.7),rand_range(0.4,0.7),rand_range(0.4,0.7)]
		color_max = [base_color[0]+rand_range(0.2,0.3),base_color[1]+rand_range(0.2,0.3),base_color[2]+rand_range(0.2,0.3)]
#	if color_flip:
#		var temp = base_color
#		base_color = color_max
#		color_max = temp
	for row in row_tiles:
		var r = base_color[0] + ((color_max[0]-base_color[0])/row_tiles) * row
		var b = base_color[2] + ((color_max[2]-base_color[2])/row_tiles) * row
		for line in line_tiles:
			var g = base_color[1] + ((color_max[1]-base_color[1])/line_tiles) * line
			b = b + ((color_max[2]-b)/line_tiles) * line
			all_colors.append(Color(r,g,b,1))
	if color_flip:
		all_colors.invert()
	return all_colors
	
	
func instance_colors():
	var color = prepare_colors()
	var colors = color.duplicate()
	for i in row_tiles * line_tiles:
		var new_tile = color_tile.instance()
		new_tile.rect_position = all_tiles[i][0]
		new_tile.rect_min_size = Vector2(1,1)
		new_tile.rect_scale = tilesize/new_tile.rect_size
		new_tile.tilesize = tilesize
		$Tiles.add_child(new_tile)
		all_tiles[i].append(new_tile) 
	var fixpos = determin_fixes()
	for index in fixpos:
		all_tiles[index][1].fix_position()
		all_tiles[index][1].modulate = colors[index]
	var temp = 0
	for i in all_tiles.size():
		if all_tiles[i][1].fixed:
			var value = all_tiles[i][1].modulate
			colors.erase(value)
	colors.shuffle()
	temp = 0
	for i in all_tiles.size():
		if !all_tiles[i][1].fixed:
			var rgb = colors.pop_back()
			all_tiles[i][1].modulate = Color(rgb[0],rgb[1],rgb[2])
	var colors_for_move_calc := []
	for i in all_tiles:
		colors_for_move_calc.append(i[1].modulate)
	min_moves = Math.calculate_min_moves(colors_for_move_calc, all_colors.duplicate())

		
		
func determin_fixes():
	var fix_positions := []
	fix_positions.append(Math.fix_corners(row_tiles,line_tiles))
	fix_positions.append(Math.fix_sides_no_corners(row_tiles,line_tiles))
	if line_tiles > 5 and row_tiles > 5 and !line_tiles%2==0 and !row_tiles%2==0 :
		fix_positions.append(Math.fix_center(row_tiles,line_tiles))
	
	return fix_positions[randi() % (fix_positions.size())]
		
		
func check_win_condition():
	var counter = 0
	for i in all_tiles.size():
		if all_tiles[i][1].modulate == Color(all_colors[i][0],all_colors[i][1],all_colors[i][2]):	
			counter += 1
			if counter == row_tiles *line_tiles:
				running = false
				end_game()


func _input(event):
	var child_count = $Tiles.get_child_count() 
	var smallest_diff := 1000
	var reset_pos := Vector2()
	if !help and running:
		if event is InputEventScreenTouch:
			if event.pressed:
				for i in all_tiles:
					if i[1].selected:
						
						$Tiles.move_child(i[1], child_count)
						i[1].pos_diff = event.position - i[1].rect_position
						i[1].touch_pos = event.position
						i[1].choosen = true
						for j in all_tiles:
							if !j[1].choosen:
								j[1].temp_fixed = true 
			if !event.pressed:
				for i in all_tiles:
					if i[1].choosen:
						var old_tile = null
						var old_pos = i[1].rect_position
						var new_tile = i[1]
						for pos in all_tiles:
							var diff = (i[1].rect_position - pos[0]).length()
							if smallest_diff >= diff:
								smallest_diff = diff
								reset_pos = pos[0]
								if pos.size() == 2:
									old_tile = pos[1]
						if !old_tile == null and old_tile.fixed == false:
							i[1].tween_pos(i[1].rect_position, reset_pos, 0.5)
							i[1].choosen = false
							for j in all_tiles:
								if !j[1].choosen:
									j[1].temp_fixed = false 
							for pos in all_tiles:
								if pos[0] == reset_pos:
									pos[1] = i[1]
							i[1] = old_tile
							i[1].tween_pos(i[1].rect_position, i[0], 0.5)
						else:
							i[1].tween_pos(i[1].rect_position, i[0], 0.5)
							i[1].choosen = false
							for j in all_tiles:
								if !j[1].choosen:
									j[1].temp_fixed = false 
				check_win_condition()
				moves_done += 1
		if event is InputEventScreenDrag:
			for i in all_tiles:
				if i[1].choosen:
					i[1].touch_pos = event.position

					
func end_game():
	
	confetti.restart()
	time_on = false
	var secs = fmod(time,60)
	var mins = fmod(time,60*60)/60
	var time_passed = "%02d : %02d" % [mins,secs]
	time_label.text = time_passed
	
	moves_label.text = str(moves_done)
	
	
	$GUI/MarginContainer.hide()
	$End_Game/End_Game_UI.show()
	
	
	
func _process(delta):
	if time_on:
		time += delta 

func _on_Easy_pressed():
	$UI/UI.hide()
	easy = true
	start_game()


func _on_Moderate_pressed():
	$UI/UI.hide()
	moderate = true
	start_game()


func _on_Hard_pressed():
	$UI/UI.hide()
	hard = true
	start_game()


func _on_Extrem_pressed():
	$UI/UI.hide()
	extrem = true
	start_game()


func _on_Next_Level_pressed():
	var children = $Tiles.get_children()
	for i in children:
		i.queue_free()
	$End_Game/End_Game_UI.hide()
	all_colors.clear()
	all_tiles.clear()
	if custom:
		$CustomUI/CustomUI.show()
		$GUI/MarginContainer.hide()
	else:
		start_game()
		


func _on_Change_Difficultie_pressed():
	var children = $Tiles.get_children()
	for i in children:
		i.queue_free()
	$End_Game/End_Game_UI.hide()
	all_colors.clear()
	all_tiles.clear()
	easy = false
	moderate = false
	hard = false
	extrem = false
	custom = false
	$UI/UI.show()
	
	
	
func _on_Game_Selection_pressed():
	get_tree().change_scene("res://GameMode_Selection/GameModeSelection.tscn")
	


func _on_Restart_pressed():
	var children = $Tiles.get_children()
	for i in children:
		i.queue_free()
	all_colors.clear()
	all_tiles.clear()
	start_game()


func _on_BackToModes_pressed():
	get_tree().change_scene("res://GameMode_Selection/GameModeSelection.tscn")


func _on_Custom_pressed():
	custom = true
	$UI/UI.hide()
	$CustomUI/CustomUI.show()
	

func custom_game(rows, lines, color_min, color_max):
	row_tiles = rows
	line_tiles = lines
	custom_color1 = color_min
	custom_color2 = color_max
	$CustomUI/CustomUI.hide()
	start_game()


func _on_Help_pressed():
	help = true
	var timer_time
	if row_tiles < 7 and line_tiles < 7:
		timer_time = 0.075
	elif row_tiles < 10 and line_tiles < 10:
		timer_time = 0.05
	elif row_tiles <= 15 and line_tiles <= 15:
		timer_time = 0.03
	$GUI/MarginContainer/HBoxContainer/Restart.disabled = true
	$GUI/MarginContainer/HBoxContainer/Help.disabled = true
	$GUI/MarginContainer/HBoxContainer/BackToModes.disabled = true
	for index in all_tiles.size():
		if !all_tiles[index][1].fixed:
			all_tiles[index][1].tween_color(all_colors[index])
			yield(get_tree().create_timer(timer_time), "timeout")
	yield(get_tree().create_timer(3), "timeout")
	for index in all_tiles.size():
		if !all_tiles[index][1].fixed:
			if all_tiles[index][1].color_fixed:
				all_tiles[index][1].tween_reset_color()
				yield(get_tree().create_timer(timer_time), "timeout")
	yield(get_tree().create_timer(1), "timeout")
	$GUI/MarginContainer/HBoxContainer/Restart.disabled = false
	$GUI/MarginContainer/HBoxContainer/Help.disabled = false
	$GUI/MarginContainer/HBoxContainer/BackToModes.disabled = false
	help = false
