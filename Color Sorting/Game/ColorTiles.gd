extends ColorRect

onready var tween = $Tween
onready var mark = $TextureRect
onready var touch_button = $TouchScreenButton

var selected = false
var choosen = false
var fixed = false
var temp_fixed = false
var color_fixed = false
var touch_pos := Vector2()
var tilesize := Vector2()

var pos_diff
var orig_pos := Vector2()
var orig_color = null


func _ready():
	mark.hide()
	mark.rect_min_size = rect_min_size
	touch_button.shape.set_extents(rect_size/2)

	

func _process(delta):
	if !fixed and !temp_fixed and !color_fixed:
		if choosen:
			rect_position = touch_pos - pos_diff 




func tween_pos(startpos, endpos, duration):
	tween.interpolate_property(self, "rect_position", startpos, endpos, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	
func fix_position():
	fixed = true
	set_process(false)
	mark.show()
	
	


func _on_TouchScreenButton_pressed():
	selected = true




func _on_TouchScreenButton_released():
	selected = false



func tween_color(color):
	color_fixed = true
	if orig_color == null:
		orig_color = modulate
	tween.interpolate_property(self, "modulate", orig_color, color, 1)
	tween.start()



func tween_reset_color():
	tween.interpolate_property(self, "modulate", modulate, orig_color, 1)
	tween.start()
	yield(tween, "tween_completed")
	color_fixed = false
	
