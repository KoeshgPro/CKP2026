extends Sprite2D

func _process(_delta: float) -> void:
	if Global.Score >= 400:
			$".".show()
	elif !Global.Score >= 400:
		$".".hide()
