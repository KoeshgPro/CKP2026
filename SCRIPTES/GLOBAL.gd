extends Node

var Score = 0

var current_user = ""


func add_score(amount: int) -> void:
	Score += amount
	
	AcountSystem.save_player_score(Global.Score)
