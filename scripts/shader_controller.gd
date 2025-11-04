extends ColorRect

##for when charley is close
var enemy_is_close = false
@export var scanline_speed = 0.75
var scanline_up = true
var scanline_thickness = 0.75: 
	get(): return scanline_thickness
	set(val):
		scanline_thickness = val
		scanline_thickness = clampf(val,0.0,1.0)
		material.set_shader_parameter("sharpness",val)

var scanline_brightness = 1.0: 
	get(): return scanline_brightness
	set(val):
		scanline_brightness = val
		scanline_brightness = clampf(val,0.25,1.0)
		material.set_shader_parameter("scanline_brightness",val)

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if enemy_is_close :
		if scanline_up:
			scanline_thickness += delta * scanline_speed
			scanline_brightness += delta * scanline_speed
			if scanline_thickness >= 1:
				scanline_up = false
		else:
			scanline_thickness -= delta * scanline_speed
			scanline_brightness -= delta * scanline_speed
			if scanline_thickness <= 0:
				scanline_up = true
			
		
##when player dies
func fade_to_black(time = 1.0):
	enemy_is_close = false
	var tween = get_tree().create_tween()
	tween.tween_property(self,"scanline_brightness",0.0,time)


#reset shader after charley is not near anymore
func reset_shader():
	enemy_is_close = false
	scanline_thickness = 0.75
	scanline_brightness = 1.0
	
