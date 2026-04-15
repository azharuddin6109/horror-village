extends Node3D

func _ready():
	var static_body = StaticBody3D.new()
	add_child(static_body)
	var col = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 0.3
	shape.height = 5.0
	col.shape = shape
	static_body.add_child(col)
