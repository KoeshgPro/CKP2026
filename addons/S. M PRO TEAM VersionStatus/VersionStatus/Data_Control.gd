extends Control
@export_placeholder("1.0.0") var Your_game_version = ""
@export_placeholder("SMP-XXXXXXXX") var project_id = ""
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
var url : String = "https://s-m-pro.onrender.com/dashboard"
@export var update_button: Control = null
@export var skip: Control = null
var _connected: bool = false
var _is_exiting: bool = false
func _physics_process(delta: float) -> void:
	if _is_exiting == true:
		AcountSystem.test_mode = 1
	else:
		AcountSystem.test_mode = 0
func _enter_tree() -> void:
	_is_exiting = false
	if VersionStatus:
		if not Your_game_version.is_empty():
			VersionStatus.Your_game_version = Your_game_version
		if not project_id.is_empty():
			VersionStatus.project_id = project_id
func _ready() -> void:
	if is_instance_valid(update_button):
		if update_button.has_signal("pressed"):
			if not update_button.pressed.is_connected(_on_update_pressed):
				update_button.pressed.connect(_on_update_pressed)
	else:
		push_warning("[VersionStatus] لم يتم تعيين update_button من Inspector")
	if is_instance_valid(skip):
		if skip.has_signal("pressed"):
			if not skip.pressed.is_connected(_on_skip_pressed):
				skip.pressed.connect(_on_skip_pressed)
	else:
		push_warning("[VersionStatus] لم يتم تعيين skip من Inspector")
	if not VersionStatus.update_status_changed.is_connected(_on_update_status_changed):
		VersionStatus.update_status_changed.connect(_on_update_status_changed)
		_connected = true
	if VersionStatus.ooo == false:
		VersionStatus.Server_Connection()
	_on_update_status_changed()
func _exit_tree() -> void:
	_is_exiting = true
	if _connected and VersionStatus:
		if VersionStatus.update_status_changed.is_connected(_on_update_status_changed):
			VersionStatus.update_status_changed.disconnect(_on_update_status_changed)
		_connected = false
func _on_update_status_changed() -> void:
	if _is_exiting or not is_inside_tree():
		return
	if VersionStatus == null:
		return
	if VersionStatus.update == true:
		show()
	else:
		hide()
	if VersionStatus.supposed == true and visible == true:
		if is_instance_valid(skip):
			skip.hide()
func _on_update_pressed():
	if VersionStatus == null:
		return
	if VersionStatus.update_url.is_empty():
		push_warning("[VersionStatus] لا يوجد رابط تحديث")
		return
	OS.shell_open(VersionStatus.update_url)
func _on_skip_pressed():
	AcountSystem.test_mode = 0
	if _is_exiting or not is_inside_tree():
		return
	hide()
	if VersionStatus:
		VersionStatus.update = false
