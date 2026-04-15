extends Node

var keys_collected = 0
var has_axe = false
var health = 100.0
var axe_node = null
var axe_original_position = Vector3.ZERO
var player_in_house = false
var ghost_active = false
var ghost_warning = false
var ghost_timer = 0.0
var ghost_interval = 30.0
var player_alive = true
var player_frozen = false
var save_path = "user://savegame.cfg"

func reset_all():
	keys_collected = 0
	has_axe = false
	health = 100.0
	axe_node = null
	player_in_house = false
	ghost_active = false
	ghost_warning = false
	ghost_timer = 0.0
	ghost_interval = 30.0
	player_alive = true
	player_frozen = false

func collect_key():
	keys_collected += 1
	if keys_collected >= 4:
		ghost_interval = 15.0

func respawn_axe():
	var new_axe = load("res://axe.glb").instantiate()
	new_axe.set_script(load("res://axe.gd"))
	new_axe.global_position = axe_original_position
	var scene = get_tree().current_scene
	if scene:
		scene.call_deferred("add_child", new_axe)
		print("Axe respawned at: ", axe_original_position)
func _process(delta):
	if not player_alive:
		return
	if not ghost_active and not ghost_warning:
		ghost_timer += delta
		if ghost_timer >= ghost_interval:
			ghost_timer = 0.0
			start_ghost_warning()

func start_ghost_warning():
	ghost_warning = true
	var hud = get_tree().root.find_child("HUD", true, false)
	if hud:
		hud.start_ghost_countdown(18)

func save_game():
	var config = ConfigFile.new()
	config.set_value("game", "keys_collected", keys_collected)
	config.set_value("game", "has_axe", has_axe)
	config.set_value("game", "health", health)
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		config.set_value("game", "player_x", player.global_position.x)
		config.set_value("game", "player_y", player.global_position.y)
		config.set_value("game", "player_z", player.global_position.z)
	config.save(save_path)
	print("Game saved!")

func has_save():
	return FileAccess.file_exists(save_path)

func load_game():
	var config = ConfigFile.new()
	if config.load(save_path) == OK:
		keys_collected = config.get_value("game", "keys_collected", 0)
		has_axe = config.get_value("game", "has_axe", false)
		health = config.get_value("game", "health", 100.0)
		print("Game loaded!")
		return config
	return null

func delete_save():
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
