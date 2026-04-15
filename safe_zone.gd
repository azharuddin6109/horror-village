extends Node3D

var zone_area = null

func _ready():
	call_deferred("setup")

func setup():
	var circle_mesh = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 3.0
	cylinder.bottom_radius = 3.0
	cylinder.height = 0.05
	circle_mesh.mesh = cylinder

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 1, 0, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0, 1, 0)
	mat.emission_energy_multiplier = 1.5
	circle_mesh.material_override = mat
	circle_mesh.position = Vector3(0, 0.1, 0)
	add_child(circle_mesh)

	zone_area = Area3D.new()
	zone_area.collision_layer = 0
	zone_area.collision_mask = 1
	zone_area.monitoring = true
	var shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(6, 5, 6)
	shape.shape = box
	zone_area.add_child(shape)
	add_child(zone_area)
	zone_area.body_entered.connect(_on_player_enter)
	zone_area.body_exited.connect(_on_player_exit)
	print("Safe zone created at: ", global_position)

func _on_player_enter(body):
	if body.name == "Player":
		GameManager.player_in_house = true
		print("Player is SAFE in zone")

func _on_player_exit(body):
	if body.name == "Player":
		GameManager.player_in_house = false
		print("Player LEFT safe zone")
