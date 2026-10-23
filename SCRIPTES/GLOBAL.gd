extends Node

signal score_changed(new_score: int)

var Score: int = 0
var current_user: String = ""
var exam_num: int = 1

func EXAM(_exam: int) -> void:
	pass

func add_score(amount: int) -> void:
	Score += amount
	score_changed.emit(Score)
	AcountSystem.save_player_score(Score)

func set_score(val: int) -> void:
	Score = val
	score_changed.emit(Score)
