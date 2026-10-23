extends Sprite2D

func _ready() -> void:
	_update_visibility(Global.Score)
	if Global.has_signal("score_changed"):
		Global.score_changed.connect(_update_visibility)

func _update_visibility(_current_score: int) -> void:
	if Global.Score >= 0:
		show()
		var root_tag = get_parent().get_parent() if get_parent() else null
		if root_tag:
			root_tag.show()
	else:
		var root_tag = get_parent().get_parent() if get_parent() else null
		if root_tag:
			root_tag.hide()
