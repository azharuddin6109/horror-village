extends Node3D

var speed = 8.0
var player = null
var chasing = false
var attack_timer = 0.0
var outside_timer = 0.0
var waiting_outside = false
var anim_player = null
var freezing_player = false
var ghost_scale = Vector3(1.4, 1.4, 1.4)
var ray = null
var ghost_sound = null

func _ready():
	visible = false
	set_physics_process(false)
	anim_player = find_children("*", "AnimationPlayer", true)
	if anim_player.size() > 0:
		anim_player = anim_player[0]
		print("Ghost animations: ", anim_player.get_animation_list())
	else:
		anim_player = null

	ray = RayCast3D.new()
	ray.target_position = Vector3(0, -50, 0)
	ray.enabled = true
	add_child(ray)
	
	ghost_sound = AudioStreamPlayer.new()
	ghost_sound.stream = load("res://ghost.mp3")
	add_child(ghost_sound)

func get_ground_height(pos):
	ray.global_position = Vector3(pos.x, pos.y + 20, pos.z)
	ray.force_raycast_update()
	if ray.is_colliding():
		return ray.get_collision_point().y
	return player.global_position.y

func appear():
	player = get_tree().root.find_child("Player", true, false)
	if not player:
		return

	print("Ghost appearing, player_in_house: ", GameManager.player_in_house)

	if GameManager.player_in_house:
		visible = false
		waiting_outside = true
		outside_timer = 5.0
		set_physics_process(true)
		var hud = get_tree().root.find_child("HUD", true, false)
		if hud:
			hud.show_door_text("You are safe! The ghost is outside...")
	else:
		visible = true
		scale = ghost_scale
		ghost_sound.play()
		var cam = player.get_node("Head/Camera3D")
		var forward = -cam.global_transform.basis.z.normalized()
		forward.y = 0
		forward = forward.normalized()
		var spawn_pos = player.global_position + forward * 4.0
		spawn_pos.y = get_ground_height(spawn_pos)
		global_position = spawn_pos

		var look_pos = player.global_position
		look_pos.y = global_position.y
		if look_pos != global_position:
			look_at(look_pos)
			rotate_y(deg_to_rad(180))

		freezing_player = true
		GameManager.player_frozen = true

		chasing = true
		attack_timer = 3.0
		if anim_player:
			anim_player.play(anim_player.get_animation_list()[0])
		set_physics_process(true)

func _physics_process(delta):
	if not GameManager.player_alive:
		return

	scale = ghost_scale

	if waiting_outside:
		outside_timer -= delta
		if outside_timer <= 0:
			disappear()
		return

	if chasing and player:
		if GameManager.player_in_house:
			disappear()
			var hud = get_tree().root.find_child("HUD", true, false)
			if hud:
				hud.show_door_text("You made it! The ghost is gone!")
			return

		var distance = global_position.distance_to(player.global_position)
		if distance > 3.0:
			var direction = (player.global_position - global_position).normalized()
			direction.y = 0
			global_position += direction * speed * delta
			global_position.y = get_ground_height(global_position)
		look_at_player()
		scale = ghost_scale

		attack_timer -= delta
		if attack_timer <= 0:
			kill_player()

func look_at_player():
	if player:
		var look_pos = player.global_position
		look_pos.y = global_position.y
		if look_pos != global_position:
			look_at(look_pos)
			rotate_y(deg_to_rad(180))

func kill_player():
	GameManager.player_alive = false
	chasing = false
	freezing_player = false
	set_physics_process(false)
	var hud = get_tree().root.find_child("HUD", true, false)
	if hud:
		hud.show_death_screen()

func disappear():
	visible = false
	chasing = false
	waiting_outside = false
	freezing_player = false
	GameManager.player_frozen = false
	set_physics_process(false)
	GameManager.ghost_active = false
	if ghost_sound.playing:
		ghost_sound.stop()
	if anim_player:
		anim_player.stop()
	var hud = get_tree().root.find_child("HUD", true, false)
	if hud:
		hud.hide_door_text()
