extends Node3D

var player_nearby = false

func _ready():
	call_deferred("setup")

func setup():
	var meshes = find_children("*", "MeshInstance3D", true)
	for mesh in meshes:
		if mesh.mesh != null:
			mesh.create_trimesh_collision()

	# Create red glowing circle on the ground
	var circle_mesh = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 2.5
	cylinder.bottom_radius = 2.5
	cylinder.height = 0.05
	circle_mesh.mesh = cylinder

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0, 0, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1, 0, 0)
	mat.emission_energy_multiplier = 2.0
	circle_mesh.material_override = mat

	get_tree().root.add_child(circle_mesh)
	circle_mesh.global_position = Vector3(global_position.x - 5.0, 0.15, global_position.z)

	# Create detection area at same spot
	var area = Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitoring = true
	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 3.0
	shape.shape = sphere
	area.add_child(shape)
	get_tree().root.add_child(area)
	area.global_position = circle_mesh.global_position
	area.body_entered.connect(_on_player_enter)
	area.body_exited.connect(_on_player_exit)

	print("Circle placed at: ", circle_mesh.global_position)

func _on_player_enter(body):
	if body.name == "Player":
		player_nearby = true
		var hud = get_tree().root.find_child("HUD", true, false)
		if hud:
			if GameManager.keys_collected >= 5:
				hud.show_door_text("Press E to ESCAPE!")
			else:
				hud.show_door_text("I need " + str(5 - GameManager.keys_collected) + " keys to open this door and escape this island!")

func _on_player_exit(body):
	if body.name == "Player":
		player_nearby = false
		var hud = get_tree().root.find_child("HUD", true, false)
		if hud:
			hud.hide_door_text()

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		if GameManager.keys_collected >= 5:
			open_door()

func open_door():
	var hud = get_tree().root.find_child("HUD", true, false)
	if hud:
		hud.show_win_screen()
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", rotation.y + PI / 2, 2.0)
