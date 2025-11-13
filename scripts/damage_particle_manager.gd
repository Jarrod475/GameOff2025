extends CPUParticles3D

func _ready() -> void:
	$"..".health_changed.connect(emit_particles)
	
func emit_particles(_val):
	emitting = true
