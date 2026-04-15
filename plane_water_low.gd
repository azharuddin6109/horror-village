extends Node3D

func _ready():
	call_deferred("setup")

func setup():
	var anim_player = find_child("AnimationPlayer", true)
	if anim_player:
		var anims = anim_player.get_animation_list()
		if anims.size() > 0:
			# Set to loop then play
			anim_player.get_animation(anims[0]).loop_mode = Animation.LOOP_LINEAR
			anim_player.play(anims[0])
			print("✅ Looping: " + anims[0])
