extends CharacterBody2D

const speed = 100
var Gravity = 50
var where = 0
@onready var REACT: Node2D = $Node2D2

func _ready() -> void:
	REACT.hide()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("use"):
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
