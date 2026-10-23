extends Node2D


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("use"):
		if Global.exam_num == 5:
			print(Global.exam_num)
			get_tree().change_scene_to_file("res://SCENES/WORLDS/quiz.tscn")
		elif Global.exam_num == 6:
			print(Global.exam_num)
			get_tree().change_scene_to_file("res://SCENES/WORLDS/quiz.tscn")
		else:
			if Global.exam_num == 7:
				print(Global.exam_num)
				get_tree().change_scene_to_file("res://SCENES/WORLDS/quiz.tscn")
			elif Global.exam_num == 8:
				print(Global.exam_num)
				get_tree().change_scene_to_file("res://SCENES/WORLDS/quiz.tscn")
