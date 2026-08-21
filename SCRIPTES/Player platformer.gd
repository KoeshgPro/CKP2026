extends CharacterBody2D

const speed = 100
var Gravity = 50
var where = 0
@onready var REACT: Node2D = $Node2D2

func _ready() -> void:
	REACT.hide()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("use"):
		if get_tree().current_scene.scene_file_path == "res://SCENES/WORLDS/level_1.tscn":
			pass
		if get_tree().current_scene.scene_file_path == "res://SCENES/WORLDS/level_2.tscn":
			pass
		if get_tree().current_scene.scene_file_path == "res://SCENES/WORLDS/level_3.tscn":
			pass
	move_and_slide()
	if Input.is_action_pressed("right"):
		$AnimatedSprite2D.play("MOVING")
		$AnimatedSprite2D.flip_h = false
		velocity.x = speed
	elif Input.is_action_pressed("left"):
		$AnimatedSprite2D.play("MOVING")
		$AnimatedSprite2D.flip_h = true
		velocity.x = -speed
	else:
		$AnimatedSprite2D.play("IDLE")
		velocity.x = 0
	
	if !is_on_floor():
		velocity.y = Gravity




func _on_react_area_body_entered(_body: Node2D) -> void:
	REACT.show()
	pass # Replace with function body.


func _on_react_area_body_exited(_body: Node2D) -> void:
	if where == 0:
		REACT.hide()
	pass # Replace with function body.



@warning_ignore("unused_parameter")
func _on_lesson_1_body_entered(body: Node2D) -> void:
	where = 1
	pass # Replace with function body.


@warning_ignore("unused_parameter")
func _on_lesson_1_body_exited(body: Node2D) -> void:
	where = 0
	pass # Replace with function body.


@warning_ignore("unused_parameter")
func _on_lesson_2_body_entered(body: Node2D) -> void:
	where = 2
	pass # Replace with function body.


@warning_ignore("unused_parameter")
func _on_lesson_2_body_exited(body: Node2D) -> void:
	if where == 2:
		where = 0
	pass # Replace with function body.


@warning_ignore("unused_parameter")
func _on_lesson_3_body_entered(body: Node2D) -> void:
	where = 3
	pass # Replace with function body.





@warning_ignore("unused_parameter")
func _on_lesson_3_body_exited(body: Node2D) -> void:
	if where == 3:
		where = 0
	pass # Replace with function body.


@warning_ignore("unused_parameter")
func _on_lesson_4_body_entered(body: Node2D) -> void:
	where = 4
	pass # Replace with function body.


@warning_ignore("unused_parameter")
func _on_lesson_4_body_exited(body: Node2D) -> void:
	if where == 4:
		where = 0
	pass # Replace with function body.
