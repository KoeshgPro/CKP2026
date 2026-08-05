extends CanvasLayer

@onready var progress_bar: ProgressBar = $Node2D/ProgressBar
@onready var label: Label = $Node2D/Label



func _process(_delta: float) -> void:
	if AcountSystem.current_user == "":
		$Label.text = "يرجى اعادة تشغيل اللعبة"
	else:
		$Label.text = "الحساب المستخدم : " + AcountSystem.current_user
	if AcountSystem.current_user == "ADMIN":
		$"ADMIN PANEL".show()
	progress_bar.value = Global.Score
	label.text = str(Global.Score)
	if Global.Score >= 400:
		progress_bar.hide()
		label.text = "Score : " + str(Global.Score)
	elif !Global.Score >= 400:
		progress_bar.show()
		label.text = str(Global.Score)
	pass


func _on_button_pressed():
	Global.add_score(10)
	pass # Replace with function body.
	


func _on_log_out_pressed() -> void:
	AcountSystem.logout()
	pass # Replace with function body.


func _on_minus_10_pressed() -> void:
	Global.add_score(-10)
	pass # Replace with function body.
