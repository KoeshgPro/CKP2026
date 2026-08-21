extends CharacterBody2D

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var REACT: Node2D = $Node2D2


var where = 0
var speed = 100
var React = 0

func _ready() -> void:
	where = 0


func _physics_process(_delta):
	if Input.is_action_just_pressed("use"):
		print(where)
		if where == 1:
			get_tree().change_scene_to_file("res://SCENES/WORLDS/level_1.tscn")
		elif where == 2:
			get_tree().change_scene_to_file("res://SCENES/WORLDS/level_2.tscn")
		elif where == 3:
			get_tree().change_scene_to_file("res://SCENES/WORLDS/level_3.tscn")
		else:
			print("مفيش اماكن تروحها هنا")
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	
	if direction == Vector2.ZERO:
		animated.play("IDLE")
	else:
		animated.play("MOVING")
	if direction.x != 0:
		animated.flip_h = direction.x < 0


func _on_small_pyramid_body_entered(_body: Node2D) -> void:
	React = 1
	where = 1
	pass # Replace with function body.


func _on_miduim_body_entered(_body: Node2D) -> void:
	React = 2
	where = 2
	pass # Replace with function body.


func _on_big_body_entered(_body: Node2D) -> void:
	React = 3
	where = 3
	pass # Replace with function body.


func _on_big_body_exited(_body: Node2D) -> void:
	if where == 3:
		React = 0
		where = 0
	pass # Replace with function body.


func _on_miduim_body_exited(_body: Node2D) -> void:
	if where == 2:
		React = 0
		where = 0
	pass # Replace with function body.


func _on_small_pyramid_body_exited(_body: Node2D) -> void:
	if where == 1:
		React = 0
		where = 0
	pass # Replace with function body.
