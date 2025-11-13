extends AudioStreamPlayer3D

@export var gunshot : AudioStream

func _ready() -> void:
	$"..".shooting.connect(play_shoot)

func play_shoot():
	stream = gunshot
	play()
