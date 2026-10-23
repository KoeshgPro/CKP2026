extends Node2D

@warning_ignore("shadowed_global_identifier")
@onready var char: CharacterBody2D = $".."

func _ready() -> void:
	if char:
		char.React = 0
	hide()

@warning_ignore("unused_parameter")
func _physics_process(_delta: float) -> void:
	if char:
		visible = (char.React != 0)
