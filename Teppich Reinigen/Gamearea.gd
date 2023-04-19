extends Node2D


onready var cleaner = preload("res://Teppich Reinigen/Cleaner.tscn")
onready var carpet_pic = preload("res://Teppich Reinigen/teppich_1.png")
onready var carpet = get_node("Carpet")

var viewport_size := Vector2()


func _ready():
	get_viewport_data()
	instance_cleaner()
	instance_carpet()
	
	
func get_viewport_data():
	viewport_size = get_viewport().size
	
	
func instance_cleaner():
	var new_cleaner = cleaner.instance()
	add_child(new_cleaner)
	
	
func instance_carpet():
	var carpet_size = calculate_size()
	carpet.texture = carpet_pic
	carpet.rect_position = Vector2(viewport_size.x/10, viewport_size.y/6)
	carpet.rect_size = carpet_size
	print(carpet_size)

func calculate_size():
	var x_line:float = float(viewport_size.x) - float(2*viewport_size.x/10)
	var y_line:float = float(viewport_size.y) - float(2*viewport_size.y/6)
#	tilesize = Vector2(int(x_line/line_tiles) +1, int(y_line/row_tiles)+1)
#	print(tilesize)
	return Vector2(x_line, y_line)
