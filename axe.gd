extends Node3D

var player_nearby = false

func _ready():
	print("Axe ready at position: ", global_position)
	if GameManager.axe_original_position == Vector3.ZERO:
		GameManager.axe_original_position = global_position
		print("Saved axe position: ", global_position)
	call_deferred("setup")

func setup():
	var area = Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitoring = true
	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 3.0
	shape.shape = sphere
	area.add_child(shape)
	add_child(area)
	area.body_entered.connect(_on_player_enter)
	area.body_exited.connect(_on_player_exit)
	print("Axe pickup area ready")

func _on_player_enter(body):
	if body.name == "Player":
		player_nearby = true
		print("Player near axe")
		var hud = get_tree().root.find_child("HUD", true, false)
		if hud:
			hud.show_door_text("Press E to pick up the axe!")

func _on_player_exit(body):
	if body.name == "Player":
		player_nearby = false
		var hud = get_tree().root.find_child("HUD", true, false)
		if hud:
			hud.hide_door_text()

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		if not GameManager.has_axe:
			GameManager.has_axe = true
			print("Axe picked up!")

			var player = get_tree().root.find_child("Player", true, false)
			if player:
				var head = player.get_node("Head")
				var axe_model = load("res://axe.glb").instantiate()
				axe_model.name = "FPPAxe"
				axe_model.position = Vector3(0.5, -0.4, -0.8)
				axe_model.rotation_degrees = Vector3(-10, 180, -45)
				axe_model.scale = Vector3(0.4, 0.4, 0.4)
				head.add_child(axe_model)
				GameManager.axe_node = axe_model

			var hud = get_tree().root.find_child("HUD", true, false)
			if hud:
				hud.show_door_text("Axe collected!")
			queue_free()
