extends Node
signal update_status_changed
@export var Your_game_version : String = "1.0.0"
@export var project_id : String = "SMP-XXXXXXXX"
var c_url = "https://s-m-pro-gaming-central-server.onrender.com/Version_Management/Status?id="
const MAX_RETRIES: int = 3
const RETRY_DELAYS: Array = [4.0, 5.0, 6.0]
var CACHE_PATH = OS.get_user_data_dir() + "Data_SmPro_VS.json"
const CACHE_KEY_BASE := "SmPRO_VS_v1_Key_2026"
var _update = false
var update: bool:
	get:
		return _update
	set(value):
		if _update != value:
			_update = value
			update_status_changed.emit()
var update_url = ""
var supposed = false
var _http_request: HTTPRequest
var _retry_count: int = 0
var ooo = false
var _request_in_flight: bool = false
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_http_request = HTTPRequest.new()
	_http_request.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)
func Server_Connection():
	_retry_count = 0
	update = false
	update_url = ""
	supposed = false
	_send_request()
func _send_request() -> void:
	if not is_inside_tree() or _http_request == null or not is_instance_valid(_http_request):
		return
	var url = c_url + project_id
	var total_attempts = MAX_RETRIES + 1
	print("[VersionStatus] 📡 إرسال الطلب (محاولة %d/%d):" % [_retry_count + 1, total_attempts])
	print("", "Linking : ...... ")
	_request_in_flight = true
	var error = _http_request.request(url)
	if error != OK:
		_request_in_flight = false
		_handle_failure("فشل إرسال الطلب (error code: %d)" % error)
func _handle_failure(error_msg: String) -> void:
	print("[VersionStatus] ❌ ", error_msg)
	if _retry_count == 1:
		_try_cache_fallback()
	if _retry_count >= MAX_RETRIES:
		print("[VersionStatus] ⛔ استنفدت جميع المحاولات (%d محاولات)" % (MAX_RETRIES + 1))
		return
	var delay: float = RETRY_DELAYS[_retry_count]
	_retry_count += 1
	print("[VersionStatus] 🔄 إعادة المحاولة %d/%d بعد %.1f ثانية..." % [_retry_count, MAX_RETRIES, delay])
	var tree := get_tree()
	if tree == null:
		return
	await tree.create_timer(delay).timeout
	if not is_inside_tree() or get_tree() == null:
		return
	_send_request()
func _on_request_completed(result, response_code, headers, body):
	if not is_inside_tree():
		return
	_request_in_flight = false
	if result != HTTPRequest.RESULT_SUCCESS:
		_handle_failure("فشل الاتصال (result code: %d)" % result)
		return
	if response_code != 200:
		_handle_failure("رد السيرفر بكود HTTP: %d" % response_code)
		return
	var response_text = body.get_string_from_utf8()
	var data = JSON.parse_string(response_text)
	if data == null or not data is Dictionary:
		_handle_failure("فشل تحليل استجابة السيرفر (JSON غير صالح)")
		return
	_retry_count = 0
	var smart_enabled = data.get("smart", false) == true
	if smart_enabled:
		_save_cache(data)
	else:
		_clear_cache()
	if data.has("num-version"):
		var server_version := str(data["num-version"]).strip_edges()
		var local_version := str(Your_game_version).strip_edges()
		var cmp := _compare_versions(server_version, local_version)
		if cmp > 0:
			update = true
			print("[VersionStatus] 🔔 يوجد تحديث: %s → %s" % [local_version, server_version])
			ooo = true
		elif cmp < 0:
			update = false
			print("[VersionStatus] ⚠️ إصدار السيرفر (%s) أقل من إصدار اللعبة (%s) — تم تجاهل الإشعار" % [server_version, local_version])
		else:
			update = false
			print("[VersionStatus] ✅ اللعبة بأحدث إصدار (%s)" % local_version)
	if data.has("server-supposed"):
		if data["server-supposed"] == true:
			supposed = true
			update_status_changed.emit()
	if data.has("server-url"):
		update_url = str(data["server-url"])
func _get_cache_password() -> String:
	return CACHE_KEY_BASE + "_" + str(project_id)
func _save_cache(data: Dictionary) -> void:
	var payload := {
		"num-version": str(data.get("num-version", "")),
		"server-supposed": data.get("server-supposed", false),
		"server-url": str(data.get("server-url", "")),
		"smart": true,
		"cached_at": int(Time.get_unix_time_from_system()),
	}
	var json_str := JSON.stringify(payload)
	var file := FileAccess.open_encrypted_with_pass(CACHE_PATH, FileAccess.WRITE, _get_cache_password())
	if file:
		file.store_string(json_str)
		file.close()
		print("[VersionStatus] 💾 تم حفظ بيانات التحديث المشفّرة")
	else:
		push_warning("[VersionStatus] تعذّر حفظ البيانات المشفّرة — كود الخطأ: %d" % FileAccess.get_open_error())
func _load_cache() -> Dictionary:
	if not FileAccess.file_exists(CACHE_PATH):
		return {}
	var file := FileAccess.open_encrypted_with_pass(CACHE_PATH, FileAccess.READ, _get_cache_password())
	if not file:
		return {}
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed == null or not parsed is Dictionary:
		return {}
	return parsed
func _clear_cache() -> void:
	if not FileAccess.file_exists(CACHE_PATH):
		return
	var dir := DirAccess.open(OS.get_data_dir())
	if dir:
		dir.remove("Data_SmPro_VS.json")
		print("[VersionStatus] 🧹 تم مسح البيانات المخزّنة (التحديث الذكي معطّل)")
func _try_cache_fallback() -> void:
	var cache := _load_cache()
	if cache.is_empty():
		print("[VersionStatus] ℹ️ لا توجد بيانات مخزّنة للرجوع إليها")
		return
	var cached_version := str(cache.get("num-version", "")).strip_edges()
	var local_version := str(Your_game_version).strip_edges()
	if cached_version.is_empty():
		return
	var cmp := _compare_versions(cached_version, local_version)
	if cmp > 0:
		update = true
		print("[VersionStatus] 📦 من البيانات المخزّنة: تحديث متاح %s → %s" % [local_version, cached_version])
	elif cmp == 0:
		update = false
		print("[VersionStatus] 📦 من البيانات المخزّنة: اللعبة بأحدث إصدار (%s)" % local_version)
	else:
		update = false
		print("[VersionStatus] 📦 من البيانات المخزّنة: إصدار اللعبة أعلى من المخزّن")
	if cache.get("server-supposed", false) == true:
		supposed = true
		update_status_changed.emit()
	var cached_url := str(cache.get("server-url", ""))
	if not cached_url.is_empty():
		update_url = cached_url
func _compare_versions(v1: String, v2: String) -> int:
	var a := _parse_version(v1)
	var b := _parse_version(v2)
	var max_len := max(a.size(), b.size())
	while a.size() < max_len:
		a.append(0)
	while b.size() < max_len:
		b.append(0)
	for i in range(max_len):
		if a[i] > b[i]:
			return 1
		elif a[i] < b[i]:
			return -1
	return 0
func _parse_version(v: String) -> Array:
	var result: Array = []
	if v.is_empty():
		return [0]
	var main_part := v
	for sep in ["-", "+", "_"]:
		var idx := main_part.find(sep)
		if idx != -1:
			main_part = main_part.substr(0, idx)
	var parts := main_part.split(".")
	for p in parts:
		var digits := ""
		for c in p:
			if c >= "0" and c <= "9":
				digits += c
			else:
				break
		if digits.is_empty():
			result.append(0)
		else:
			result.append(int(digits))
	if result.is_empty():
		result.append(0)
	return result