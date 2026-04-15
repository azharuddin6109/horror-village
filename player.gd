extends CharacterBody3D
@export var speed = 5.0
@export var jump_velocity = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.002
var is_swinging = false
var walk_sound = null
@onready var head = $Head

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	walk_sound = AudioStreamPlayer.new()
	walk_sound.stream = load("res://walking.mp3")
	walk_sound.volume_db = -5
	add_child(walk_sound)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			var pause_menu = get_tree().root.find_child("PauseMenu", true, false)
			if pause_menu:
				pause_menu.queue_free()
		else:
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			var pause = Control.new()
			pause.name = "PauseMenu"
			pause.process_mode = Node.PROCESS_MODE_ALWAYS
			pause.set_anchors_preset(Control.PRESET_FULL_RECT)
			
			var bg = ColorRect.new()
			bg.color = Color(0, 0, 0, 0.7)
			bg.set_anchors_preset(Control.PRESET_FULL_RECT)
			pause.add_child(bg)
			
			var vbox = VBoxContainer.new()
			vbox.set_anchors_preset(Control.PRESET_CENTER)
			vbox.position = Vector2(-100, -60)
			vbox.size = Vector2(200, 150)
			vbox.add_theme_constant_override("separation", 15)
			pause.add_child(vbox)
			
			var resume_btn = Button.new()
			resume_btn.text = "Resume"
			resume_btn.custom_minimum_size = Vector2(200, 50)
			resume_btn.process_mode = Node.PROCESS_MODE_ALWAYS
			resume_btn.pressed.connect(func():
				get_tree().paused = false
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				pause.queue_free()
			)
			vbox.add_child(resume_btn)
			
			var menu_btn = Button.new()
			menu_btn.text = "Main Menu"
			menu_btn.custom_minimum_size = Vector2(200, 50)
			menu_btn.process_mode = Node.PROCESS_MODE_ALWAYS
			menu_btn.pressed.connect(func():
				get_tree().paused = false
				GameManager.save_game()
				get_tree().change_scene_to_file("res://main_menu.tscn")
			)
			vbox.add_child(menu_btn)
			
			get_tree().root.add_child(pause)
		return
	
	if event is InputEventMouseMotion:
		if GameManager.player_frozen:
			return
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.57, 1.57)

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	# Movement
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if GameManager.player_frozen:
		velocity.x = 0
		velocity.z = 0
		if walk_sound.playing:
			walk_sound.stop()
		move_and_slide()
		return
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if not walk_sound.playing and is_on_floor():
			walk_sound.play()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		if walk_sound.playing:
			walk_sound.stop()
	
	if not is_on_floor() and walk_sound.playing:
		walk_sound.stop()
	
	move_and_slide()

func _process(_delta):
	if GameManager.has_axe and Input.is_action_just_pressed("interact"):
		if not is_swinging and GameManager.axe_node:
			swing_axe()

func swing_axe():
	is_swinging = true
	var axe = GameManager.axe_node
	var original_rot = axe.rotation_degrees
	var tween = create_tween()
	tween.tween_property(axe, "rotation_degrees", Vector3(-70, 180, -45), 0.12)
	tween.tween_property(axe, "rotation_degrees", original_rot, 0.12)
	tween.tween_callback(func(): is_swinging = false)
