extends CharacterBody2D

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var REACT: Node2D = $Node2D2
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var where: int = 0
const speed: float = 100.0
var React: int = 0

func _ready() -> void:
	where = 0
	React = 0
	

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("use"):
		if where == 1:
			get_tree().change_scene_to_file("res://SCENES/WORLDS/level_1.tscn")
		elif where == 2:
			get_tree().change_scene_to_file("res://SCENES/WORLDS/level_2.tscn")
		elif where == 3:
			get_tree().change_scene_to_file("res://SCENES/WORLDS/level_3.tscn")
		elif where == 0:
			print("noe")
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	
	if direction == Vector2.ZERO:
		$CPUParticles2D.emitting = false
		animated.play("IDLE")
		audio_stream_player_2d.play()
	else:
		
		$CPUParticles2D.emitting = true
		animated.play("MOVING")
	if direction.x != 0:
		animated.flip_h = direction.x < 0

func _on_small_pyramid_body_entered(_body: Node2D) -> void:
	if where == 0:
		React = 1
		where = 1

func _on_miduim_body_entered(_body: Node2D) -> void:
	if where == 0:
		React = 2
		where = 2

func _on_big_body_entered(_body: Node2D) -> void:
	if where == 0:
		React = 3
		where = 3

func _on_big_body_exited(_body: Node2D) -> void:
	if where == 3:
		React = 0
		where = 0

func _on_miduim_body_exited(_body: Node2D) -> void:
	if where == 2:
		React = 0
		where = 0

func _on_small_pyramid_body_exited(_body: Node2D) -> void:
	if where == 1:
		React = 0
		where = 0
