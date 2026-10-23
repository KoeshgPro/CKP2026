extends Panel

@onready var user_edit: LineEdit = $"كلمة المرور ادخال"
@onready var pass_edit: LineEdit = $"اسم المستخدم ادخال"
@onready var status_label: RichTextLabel = $"اسم المستخدم2"

func _ready() -> void:
	if pass_edit:
		pass_edit.secret = true
	if not AcountSystem.account_action_success.is_connected(_on_success):
		AcountSystem.account_action_success.connect(_on_success)
	if not AcountSystem.account_action_failed.is_connected(_on_fail):
		AcountSystem.account_action_failed.connect(_on_fail)

func _on_register_button_pressed() -> void:
	if not user_edit or not pass_edit:
		return
		
	var username = user_edit.text.strip_edges()
	var password = pass_edit.text.strip_edges()
	if username == "" or password == "":
		if status_label:
			status_label.text = "خطأ: لا يمكن ترك خانات إنشاء الحساب فارغة!"
			status_label.modulate = Color.RED
		return
	if status_label:
		status_label.text = "جاري إرسال البيانات للسيرفر الأونلاين..."
		status_label.modulate = Color.WHITE
	AcountSystem.register_user(username, password)

func _on_success(msg: String) -> void:
	if status_label:
		status_label.text = msg
		status_label.modulate = Color.GREEN
	if user_edit:
		user_edit.text = ""
	if pass_edit:
		pass_edit.text = ""

func _on_fail(msg: String) -> void:
	if status_label:
		status_label.text = msg
		status_label.modulate = Color.RED
