extends Sprite2D


func _process(_delta: float) -> void:
	if Global.Score >= 100:
		$".".show()
	elif !Global.Score >= 100:
		$".".hide()
