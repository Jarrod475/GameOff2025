extends Camera3D
var can_shoot = false

func _ready() -> void:
	$"../../../../../input_catcher".pew.connect(shoot_ray)


func shoot_ray():
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = from + -global_transform.basis.z * 1000.0  # Forward direction
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	if result.collider.is_in_group("enemy") and GunData.can_fire:
		result.collider.health -= GunData.gun_damage

	
	
	#if result:
		#print("Hit:", result.collider.name)
		#print("Hit position:", result.position)
		#print("Normal:", result.normal)
	#else:
		#print("No hit")
