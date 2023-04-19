extends CenterContainer


onready var rowlabel = get_node("VBoxContainer/Row/HBoxContainer/RowsStat")
onready var linelabel = get_node("VBoxContainer/Line/HBoxContainer/LineStats")
onready var colorbutton_1 = get_node("VBoxContainer/Colors/HBoxContainer/Color1")
onready var colorbutton_2 = get_node("VBoxContainer/Colors/HBoxContainer/Color2")
onready var rowslider = get_node("VBoxContainer/Row/RowSlider")
onready var lineslider = get_node("VBoxContainer/Line/LineSlider")

func _ready():
	rowlabel.text = str(rowslider.value)
	linelabel.text = str(lineslider.value)
	


func _on_RowSlider_value_changed(value):
	rowlabel.text = str(value)
	


func _on_LineSlider_value_changed(value):
	linelabel.text = str(value)





func _on_CustomStartButton_pressed():
	var rows = int(rowslider.value)
	var lines = int(lineslider.value)
	var color_min = colorbutton_1.color
	var color_max = colorbutton_2.color
	var parent = get_tree().get_root().get_node("Gamefield")
	parent.custom_game(rows, lines, color_min, color_max)
	
	
