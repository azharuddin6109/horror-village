extends CanvasLayer

@onready var door_label = $DoorText
@onready var key_label = $KeyCount
@onready var win_label = $WinScreen
var ghost_countdown = 0
var counting_down = false
var normal_color = Color.WHITE
var ghost_color = Color.RED
var warning_sound = null
var dead_sound = null

func _ready():
	GameManager.reset_all()
	win_label.visible = false
	door_label.visible = false
	door_label.add_theme_color_override("font_color", normal_color)
	
	warning_sound = AudioStreamPlayer.new()
	warning_sound.stream = load("res://warning.mp3")
	add_child(warning_sound)
	
	dead_sound = AudioStreamPlayer.new()
	dead_sound.stream = load("res://dead.mp3")
	add_child(dead_sound)

func _process(delta):
	if counting_down:
		ghost_countdown -= delta
		if ghost_countdown <= 0:
			counting_down = false
			door_label.text = "IT IS HERE!"
			if warning_sound.playing:
				warning_sound.stop()
			ghost_arrived()
		else:
			door_label.text = "Something is coming to attack you! Hide inside your house! " + str(int(ghost_countdown)) + "s"

func start_ghost_countdown(seconds):
	ghost_countdown = seconds
	counting_down = true
	door_label.visible = true
	door_label.add_theme_color_override("font_color", ghost_color)
	door_label.add_theme_font_size_override("font_size", 32)
	warning_sound.play()

func ghost_arrived():
	GameManager.ghost_warning = false
	GameManager.ghost_active = true
	var ghost = get_tree().root.find_child("Ghost", true, false)
	if ghost:
		ghost.appear()

func show_door_text(text):
	if not counting_down:
		door_label.text = text
		door_label.visible = true
		door_label.add_theme_color_override("font_color", normal_color)
		door_label.add_theme_font_size_override("font_size", 28)

func hide_door_text():
	if not counting_down:
		door_label.visible = false

func update_keys(count):
	key_label.text = "🔑 Keys: " + str(count) + "/5"

func show_win_screen():
	win_label.visible = true
	await get_tree().create_timer(5.0).timeout
	get_tree().quit()

func show_death_screen():
	counting_down = false
	if warning_sound.playing:
		warning_sound.stop()
	dead_sound.play()
	door_label.add_theme_color_override("font_color", ghost_color)
	door_label.add_theme_font_size_override("font_size", 40)
	door_label.text = "YOU DIED!"
	door_label.visible = true
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")
