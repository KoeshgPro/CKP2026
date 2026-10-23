extends Control

@onready var pop: AudioStreamPlayer2D = $"POP SOUND"

func _on_button_pressed() -> void:
	pop.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://SCENES/WORLDS/outside.tscn")

func _on_button_2_pressed() -> void:
	pop.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
