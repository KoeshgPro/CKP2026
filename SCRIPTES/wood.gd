extends Sprite2D





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.Score >= 0:
		$".".show()
		$"../..".show()
	elif !Global.Score >= 0:
		$"../..".hide()
	pass
