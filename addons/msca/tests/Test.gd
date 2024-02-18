extends Node2D

func _on_walk_button_pressed():
	set_non_idle_anim("Walk", 60)

func _on_run_button_pressed():
	set_non_idle_anim("Run", 100)

func set_non_idle_anim(animName, speed = 60):
	$Player.speed = speed
	$Player/Movement.non_idle_anim = animName
	$Controls/AnimLabel.text = animName
