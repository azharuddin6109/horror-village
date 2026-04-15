extends Node3D

func _ready():
	_add_collision(self)

func _add_collision(node):
	if node is MeshInstance3D:
		var n = node.name.to_lower()
		var p = node.get_parent().name.to_lower()
		var skip = ["door", "window"]
		var should_skip = false
		for word in skip:
			if word in n or word in p:
				should_skip = true
				break
		if not should_skip:
			node.create_trimesh_collision()
	for child in node.get_children():
		_add_collision(child)
