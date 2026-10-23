extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -150.0
var Gravity = 500.0

var where = 0
var exam_where = 0
var current_lesson = 0

@onready var react_node = $Node2D2
@onready var sprite = $AnimatedSprite2D

func _ready():
	if react_node:
		react_node.hide()

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://SCENES/WORLDS/outside.tscn")
		return

	if Input.is_action_just_pressed("use"):
		var exam_id = _get_exam_id()
		if exam_id > 0:
			Global.exam_num = exam_id
			Global.EXAM(exam_id)

	if not is_on_floor():
		velocity.y += Gravity * delta
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("right"):
		$CPUParticles2D.emitting = true
		sprite.play("MOVING")
		sprite.flip_h = false
		velocity.x = SPEED
	elif Input.is_action_pressed("left"):
		$CPUParticles2D.emitting = true
		sprite.play("MOVING")
		sprite.flip_h = true
		velocity.x = -SPEED
	else:
		$CPUParticles2D.emitting = false
		sprite.play("IDLE")
		velocity.x = 0

	move_and_slide()

func _get_current_level():
	var scene_path = get_tree().current_scene.scene_file_path
	if "level_2" in scene_path:
		return 2
	if "level_3" in scene_path:
		return 3
	return 1

func _get_exam_id():
	if current_lesson <= 0:
		return 0
	return (_get_current_level() - 1) * 4 + current_lesson

func _set_lesson(lesson_id):
	current_lesson = lesson_id
	where = lesson_id
	if react_node:
		react_node.show()

func _clear_lesson(lesson_id):
	if current_lesson == lesson_id:
		current_lesson = 0
		where = 0
		if react_node:
			react_node.hide()

func _on_react_area_body_entered(_body):
	if react_node and current_lesson > 0:
		react_node.show()

func _on_react_area_body_exited(_body):
	if react_node:
		react_node.hide()

func _on_lesson_1_body_entered(_body):
	_set_lesson(1)

func _on_lesson_1_body_exited(_body):
	_clear_lesson(1)

func _on_lesson_2_body_entered(_body):
	_set_lesson(2)

func _on_lesson_2_body_exited(_body):
	_clear_lesson(2)

func _on_lesson_3_body_entered(_body):
	_set_lesson(3)

func _on_lesson_3_body_exited(_body):
	_clear_lesson(3)

func _on_lesson_4_body_entered(_body):
	_set_lesson(4)

func _on_lesson_4_body_exited(_body):
	_clear_lesson(4)
