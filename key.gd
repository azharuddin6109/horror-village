extends Node3D

var player_nearby = false

func _ready():
	call_deferred("setup")

func setup():
	var area = Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitoring = true
	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 7.0
	shape.shape = sphere
	area.add_child(shape)
	add_child(area)
	area.body_entered.connect(_on_player_enter)
	area.body_exited.connect(_on_player_exit)

func _on_player_enter(body):
	if body.name == "Player":
		player_nearby = true
		var hud = get_tree().root.find_child("HUD", true, false)
		if hud:
			hud.show_door_text("Press E to pick up the key!")

func _on_player_exit(body):
	if body.name == "Player":
		player_nearby = false
		var hud = get_tree().root.find_child("HUD", true, false)
		if hud:
			hud.hide_door_text()

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		GameManager.collect_key()
		var hud = get_tree().root.find_child("HUD", true, false)
		if hud:
			hud.update_keys(GameManager.keys_collected)
			hud.hide_door_text()
		queue_free()
