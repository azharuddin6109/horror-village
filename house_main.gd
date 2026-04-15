extends Node3D

func _ready():
	print("🔧 Fixing house - walls solid, door open...")
	setup_house_collision()
	print("✅ House fixed! Walls solid, door open.")

func setup_house_collision():
	var meshes = find_children("*", "MeshInstance3D", true)
	
	for mesh in meshes:
		if mesh.mesh == null:
			continue
			
		var name_lower = mesh.name.to_lower()
		
		# These are door parts - NO collision
		if "door" in name_lower or "object_88" in name_lower or "object_78" in name_lower:
			print("🚪 Door part open: ", mesh.name)
			for child in mesh.get_children():
				if child is StaticBody3D or child is CollisionShape3D:
					child.queue_free()
			continue
		
		# Everything else = solid wall
		if not mesh.has_node("StaticBody3D"):
			var static_body = StaticBody3D.new()
			var collision_shape = CollisionShape3D.new()
			collision_shape.shape = mesh.mesh.create_trimesh_shape()
			
			if collision_shape.shape != null:
				static_body.add_child(collision_shape)
				mesh.add_child(static_body)

	print("House walls are now solid!")
