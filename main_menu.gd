extends Control

var story_showing = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Make background black
	var bg = ColorRect.new()
	bg.name = "BG"
	bg.color = Color(0, 0, 0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)
	
	# Add title
	var title = Label.new()
	title.name = "Title"
	title.text = "HORROR VILLAGE"
	title.add_theme_font_size_override("font_size", 60)
	title.add_theme_color_override("font_color", Color.RED)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(376, 80)
	title.size = Vector2(400, 80)
	add_child(title)
	
	# Center the buttons
	$VBoxContainer.position = Vector2(476, 250)
	$VBoxContainer.size = Vector2(200, 300)
	$VBoxContainer.add_theme_constant_override("separation", 15)
	
	# Style buttons
	for btn in $VBoxContainer.get_children():
		btn.add_theme_font_size_override("font_size", 24)
		btn.custom_minimum_size = Vector2(200, 50)
	
	$VBoxContainer/ContinueBtn.disabled = not GameManager.has_save()
	$VBoxContainer/NewGameBtn.pressed.connect(_on_new_game)
	$VBoxContainer/ContinueBtn.pressed.connect(_on_continue)
	$VBoxContainer/QuitBtn.pressed.connect(_on_quit)

func _on_new_game():
	GameManager.delete_save()
	GameManager.reset_all()
	show_story()

func show_story():
	story_showing = true
	
	# Hide menu stuff
	$VBoxContainer.visible = false
	get_node("Title").visible = false
	
	# Create story text
	var story = Label.new()
	story.name = "StoryText"
	story.text = "You wake up on a mysterious island with no memory of how you got here.\n\nThree old houses stand before you, and a massive locked door is your only way out.\n\nThe door has 5 keyholes. You must find all 5 keys scattered across the island.\n\nOne house is blocked by a huge rock. Find an axe to break through it.\n\nBut beware... a terrifying ghost haunts this island.\nIt appears without warning, hunting you down.\n\nYour only safety is hiding inside the houses.\n\nAfter collecting 4 keys, the ghost becomes more aggressive.\n\nFind all 5 keys, reach the door, and escape...\n\n...or die trying."
	story.add_theme_font_size_override("font_size", 22)
	story.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story.autowrap_mode = TextServer.AUTOWRAP_WORD
	story.position = Vector2(176, 40)
	story.size = Vector2(800, 500)
	add_child(story)
	
	# Add continue prompt
	var prompt = Label.new()
	prompt.name = "Prompt"
	prompt.text = "Press any key to begin..."
	prompt.add_theme_font_size_override("font_size", 20)
	prompt.add_theme_color_override("font_color", Color.RED)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.position = Vector2(376, 560)
	prompt.size = Vector2(400, 40)
	add_child(prompt)
	
	# Blink the prompt
	var tween = create_tween().set_loops()
	tween.tween_property(prompt, "modulate:a", 0.2, 0.8)
	tween.tween_property(prompt, "modulate:a", 1.0, 0.8)

func _input(event):
	if story_showing and event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://world.tscn")

func _on_continue():
	GameManager.load_game()
	get_tree().change_scene_to_file("res://world.tscn")

func _on_quit():
	get_tree().quit()
