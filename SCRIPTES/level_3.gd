extends Node2D


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("use"):
		if Global.exam_num == 9:
			print(Global.exam_num)
			get_tree().change_scene_to_file("res://SCENES/WORLDS/quiz.tscn")
		elif Global.exam_num == 10:
			print(Global.exam_num)
			get_tree().change_scene_to_file("res://SCENES/WORLDS/quiz.tscn")
		else:
			if Global.exam_num == 11:
				print(Global.exam_num)
				get_tree().change_scene_to_file("res://SCENES/WORLDS/quiz.tscn")
