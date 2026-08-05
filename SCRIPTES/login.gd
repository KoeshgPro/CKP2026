extends Control

@export var user_edit: LineEdit
@export var pass_edit: LineEdit
@export var status_label: RichTextLabel

func _ready() -> void:
	if pass_edit:
		pass_edit.secret = true
	if not AcountSystem.account_action_success.is_connected(_on_success):
		AcountSystem.account_action_success.connect(_on_success)
	if not AcountSystem.account_action_failed.is_connected(_on_fail):
		AcountSystem.account_action_failed.connect(_on_fail)

func _on_login_button_pressed() -> void:
	if not user_edit or not pass_edit or not status_label:
		print("خطأ: لم تقم بربط العقد في الـ Inspector!")
		return
		
	var email = user_edit.text.strip_edges()
	var password = pass_edit.text.strip_edges()
	
	if email == "" or password == "":
		status_label.text = "الرجاء كتابة البريد الإلكتروني وكلمة المرور!"
		status_label.modulate = Color.YELLOW
		return
		
	status_label.text = "جاري الاتصال والتحقق أونلاين..."
	status_label.modulate = Color.WHITE
	AcountSystem.login_user(email, password)

func _on_success(msg) -> void:
	status_label.text = str(msg)
	status_label.modulate = Color.GREEN
	user_edit.text = ""
	pass_edit.text = ""

func _on_fail(msg) -> void:
	status_label.text = str(msg)
	status_label.modulate = Color.RED
