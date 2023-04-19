extends Node2D

onready var touch_button_1 = get_node("Area2D/Kopfbutton")
onready var touch_buttin_2 = get_node("Saugstab/Stabbutton")

var moveable := false
var touch_pos := Vector2()
var pos_diff := Vector2()


func _ready():
	pass
	
	
	
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and moveable:
			pos_diff =  event.position - position
	if event is InputEventScreenDrag:
		touch_pos = event.position
			

func _process(delta):
	if moveable:
		position = touch_pos - pos_diff


func _on_Stabbutton_pressed():
	moveable = true


func _on_Stabbutton_released():
	moveable = false
	pos_diff = Vector2.ZERO

func _on_Kopfbutton_pressed():
	moveable = true

func _on_Kopfbutton_released():
	moveable = false
	pos_diff = Vector2.ZERO
