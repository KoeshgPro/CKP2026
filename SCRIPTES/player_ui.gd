extends CanvasLayer

@onready var progress_bar: ProgressBar = $Node2D/ProgressBar
@onready var label: Label = $Node2D/Label

func _ready() -> void:
	_update_user()
	_update_score(Global.Score)
	if Global.has_signal("score_changed"):
		Global.score_changed.connect(_update_score)

func _update_user() -> void:
	if AcountSystem.current_user == "":
		$Label.text = "يرجى تسجيل الدخول"
	else:
		$Label.text = "الحساب المستخدم : " + AcountSystem.current_user
	$"ADMIN PANEL".visible = (AcountSystem.current_user == "ADMIN" or AcountSystem.is_admin)

func _update_score(new_score: int) -> void:
	progress_bar.value = new_score
	if new_score >= 400:
		progress_bar.hide()
		label.text = "Score : " + str(new_score)
	else:
		progress_bar.show()
		label.text = str(new_score)

func _on_button_pressed() -> void:
	Global.add_score(10)

func _on_log_out_pressed() -> void:
	AcountSystem.logout()

func _on_minus_10_pressed() -> void:
	Global.add_score(-10)
