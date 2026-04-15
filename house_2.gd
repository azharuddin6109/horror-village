extends Node3D

func _ready():
	_add_collision(self)

func _add_collision(node):
	if node is MeshInstance3D:
		node.create_trimesh_collision()
	for child in node.get_children():
		_add_collision(child)
