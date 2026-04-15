extends MeshInstance3D

func _ready():
	# Remove any collision children
	for child in get_children():
		if child is StaticBody3D or child is CollisionShape3D:
			child.queue_free()
	
	print("✅ Door_55 collision completely removed!")
