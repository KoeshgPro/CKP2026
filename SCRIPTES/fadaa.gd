extends Sprite2D

func _ready() -> void:
	_update_visibility(Global.Score)
	if Global.has_signal("score_changed"):
		Global.score_changed.connect(_update_visibility)

func _update_visibility(_current_score: int) -> void:
	visible = (Global.Score >= 100)
