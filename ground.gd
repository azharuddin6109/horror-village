extends Node3D

func _ready():
	call_deferred("create_collision_for_all_meshes")

func create_collision_for_all_meshes():
	var meshes = find_children("*", "MeshInstance3D", true)
	for mesh in meshes:
		if mesh.mesh == null:
			continue
		mesh.create_trimesh_collision()
	print("✅ Ground collision added!")
