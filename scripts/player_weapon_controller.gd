extends AnimatedSprite2D

@onready var gun_light = $"../../Environment/Player/gun_light"


func _ready() -> void:
	$"../../../../input_catcher".pew.connect(shoot)
	
	

func shoot():
	if !is_playing():
		play("handgun_shoot")
		gun_light.visible = true
		await get_tree().create_timer(0.1).timeout
		gun_light.visible = false
	
