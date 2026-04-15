extends Node3D

var player_nearby = false
var hits_left = 5
var rock_area = null
var destroyed = false
var hit_sound = null
var break_sound = null

func _ready():
	hit_sound = AudioStreamPlayer.new()
	hit_sound.stream = load("res://rock_hit.mp3")
	add_child(hit_sound)
	
	break_sound = AudioStreamPlayer.new()
	break_sound.stream = load("res://rock_break.mp3")
	add_child(break_sound)
	
	call_deferred("setup")

func setup():
	var meshes = find_children("*", "MeshInstance3D", true)
	for mesh in meshes:
		if mesh.mesh != null:
			mesh.create_trimesh_collision()

	rock_area = Area3D.new()
	rock_area.collision_layer = 0
	rock_area.collision_mask = 1
	rock_area.monitoring = true
	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 3.0
	shape.shape = sphere
	rock_area.add_child(shape)
	get_tree().root.add_child(rock_area)
	rock_area.global_position = global_position
	rock_area.body_entered.connect(_on_player_enter)
	rock_area.body_exited.connect(_on_player_exit)

func _on_player_enter(body):
	if destroyed or not is_inside_tree():
		return
	if body.name == "Player":
		player_nearby = true
		update_text()

func _on_player_exit(body):
	if destroyed or not is_inside_tree():
		return
	if body.name == "Player":
		player_nearby = false
		var hud = get_tree().root.find_child("HUD", true, false)
		if hud:
			hud.hide_door_text()

func update_text():
	var hud = get_tree().root.find_child("HUD", true, false)
	if hud:
		if GameManager.has_axe:
			hud.show_door_text("Press E to hit the rock! (" + str(hits_left) + " hits left)")
		else:
			hud.show_door_text("I need an axe to break this rock...")

func _process(_delta):
	if destroyed:
		return
	if player_nearby and Input.is_action_just_pressed("interact"):
		if GameManager.has_axe:
			hits_left -= 1
			if hits_left <= 0:
				destroyed = true
				break_sound.play()
				var hud = get_tree().root.find_child("HUD", true, false)
				if hud:
					hud.show_door_text("Rock destroyed! Path is clear!")

				if GameManager.axe_node:
					GameManager.axe_node.queue_free()
					GameManager.axe_node = null
				GameManager.has_axe = false

				GameManager.respawn_axe()

				if rock_area:
					rock_area.queue_free()
				await get_tree().create_timer(1.0).timeout
				queue_free()
			else:
				hit_sound.play()
				var tween = create_tween()
				tween.tween_property(self, "position:x", position.x + 0.2, 0.05)
				tween.tween_property(self, "position:x", position.x - 0.2, 0.05)
				tween.tween_property(self, "position:x", position.x, 0.05)
				update_text()
		else:
			update_text()
