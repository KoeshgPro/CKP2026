extends Node2D

@warning_ignore("shadowed_global_identifier")
@onready var char: CharacterBody2D = $".."
func _ready() -> void:
	char.React = 0

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	print(char.React)
	if char.React == 0:
		$".".hide()
	else:
		$".".show()
