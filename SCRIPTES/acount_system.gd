extends Node

const FIREBASE_DB_URL = "https://egyptionadventure-default-rtdb.asia-southeast1.firebasedatabase.app/"
const LOCAL_SAVE_PATH = "user://saved_user.dat"
const GOOGLE_CLIENT_ID = "453005385128-jg12o9p90utmvpd7l5mk6nkp0l71rb7c.apps.googleusercontent.com"
const GOOGLE_CLIENT_SECRET = "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"
const REDIRECT_URI = "http://127.0.0.1:8080"
const FIREBASE_BASE_URL = "https://egyptionadventure-default-rtdb.asia-southeast1.firebasedatabase.app/users/"
var test_mode =  0
var current_user: String = ""
var is_admin: bool = false
var http_node: HTTPRequest
var oauth_server: TCPServer

signal account_action_success(msg)
signal account_action_failed(msg)
signal leaderboard_loaded(data)
signal admin_status_checked(is_admin_user)

func _ready() -> void:
	set_process(false)
	http_node = HTTPRequest.new()
	add_child(http_node)
	http_node.request_completed.connect(_on_request_completed)
	auto_login()

func auto_login() -> void:
	var saved_username = _load_saved_user()
	if saved_username == "":
		return
		
	var url = FIREBASE_DB_URL + "users/" + saved_username + ".json"
	var auto_http = HTTPRequest.new()
	add_child(auto_http)
	auto_http.request_completed.connect(func(_r, rc, _h, b):
		if is_instance_valid(auto_http):
			auto_http.queue_free()
		if rc == 200:
			var resp = JSON.parse_string(b.get_string_from_utf8())
			if resp is Dictionary and resp.has("password"):
				current_user = saved_username
				is_admin = resp.get("is_admin", false)
				if resp.has("score") and "set_score" in Global:
					Global.set_score(int(resp["score"]))
				Global.current_user = current_user
				emit_signal("account_action_success", "تم الدخول التلقائي بنجاح!")
				emit_signal("admin_status_checked", is_admin)
				await get_tree().create_timer(1).timeout
				var tree = Engine.get_main_loop() as SceneTree
				if tree:
					if test_mode == 0:
						tree.change_scene_to_file("res://SCENES/MAIN MENU.tscn")
				return
		_clear_saved_user()
	)
	auto_http.request(url, [], HTTPClient.METHOD_GET)

func register_user(username: String, password: String) -> void:
	if username.strip_edges() == "" or password.strip_edges() == "":
		emit_signal("account_action_failed", "الخانات فارغة!")
		return
		
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9_]+$")
	var result = regex.search(username)
	
	if not result:
		emit_signal("account_action_failed", "اسم المستخدم غير مسموح! استخدم حروف إنجليزية وأرقام فقط.")
		return
		
	var url = FIREBASE_DB_URL + "users/" + username + ".json"
	var check_http = HTTPRequest.new()
	add_child(check_http)
	check_http.request_completed.connect(func(_r, _rc, _h, b):
		if is_instance_valid(check_http):
			check_http.queue_free()
		if b.get_string_from_utf8() != "null":
			emit_signal("account_action_failed", "اسم المستخدم مسجل مسبقاً!")
		else:
			var body = JSON.stringify({"password": password, "score": 0, "is_admin": false})
			var reg_http = HTTPRequest.new()
			add_child(reg_http)
			reg_http.request_completed.connect(func(_r2, _rc2, _h2, _b2):
				if is_instance_valid(reg_http):
					reg_http.queue_free()
				_save_user_locally(username)
				current_user = username
				is_admin = false
				Global.current_user = username
				Global.set_score(0)
				emit_signal("account_action_success", "تم إنشاء الحساب أونلاين!")
			)
			reg_http.request(url, [], HTTPClient.METHOD_PUT, body)
	)
	check_http.request(url, [], HTTPClient.METHOD_GET)

func login_user(username: String, password: String) -> bool:
	var url = FIREBASE_DB_URL + "users/" + username + ".json"
	var login_http = HTTPRequest.new()
	add_child(login_http)
	login_http.request_completed.connect(func(_r, _rc, _h, b):
		if is_instance_valid(login_http):
			login_http.queue_free()
		var resp = JSON.parse_string(b.get_string_from_utf8())
		if resp is Dictionary and resp.has("password") and resp["password"] == password:
			current_user = username
			is_admin = resp.get("is_admin", false)
			_save_user_locally(username)
			Global.current_user = username
			if resp.has("score") and "set_score" in Global:
				Global.set_score(int(resp["score"]))
			emit_signal("account_action_success", "تم تسجيل الدخول بنجاح!")
			emit_signal("admin_status_checked", is_admin)
			await get_tree().create_timer(0.5).timeout
			var tree = Engine.get_main_loop() as SceneTree
			if tree:
				tree.change_scene_to_file("res://SCENES/MAIN MENU.tscn")
		else:
			emit_signal("account_action_failed", "خطأ في الاسم أو كلمة المرور")
	)
	login_http.request(url, [], HTTPClient.METHOD_GET)
	return true

func save_player_score(current_score: int) -> bool:
	if current_user == "":
		return false
	var url = FIREBASE_DB_URL + "users/" + current_user + ".json"
	var body = JSON.stringify({"score": current_score})
	var score_http = HTTPRequest.new()
	add_child(score_http)
	score_http.request_completed.connect(func(_r, _rc, _h, _b):
		if is_instance_valid(score_http):
			score_http.queue_free()
	)
	score_http.request(url, [], HTTPClient.METHOD_PATCH, body)
	return true

func get_top_scores() -> void:
	var url = FIREBASE_DB_URL + "users.json"
	http_node.request(url, [], HTTPClient.METHOD_GET)

func admin_update_user_score(target_username: String, new_score: int) -> void:
	if not is_admin:
		emit_signal("account_action_failed", "غير مسموح لك بالتعديل!")
		return
	var url = FIREBASE_DB_URL + "users/" + target_username + ".json"
	var body = JSON.stringify({"score": new_score})
	var admin_http = HTTPRequest.new()
	add_child(admin_http)
	admin_http.request_completed.connect(func(_r, rc, _h, _b):
		if is_instance_valid(admin_http):
			admin_http.queue_free()
		if rc == 200:
			emit_signal("account_action_success", "تم تعديل سكور " + target_username + " بنجاح!")
		else:
			emit_signal("account_action_failed", "فشل التعديل")
	)
	admin_http.request(url, [], HTTPClient.METHOD_PATCH, body)

func admin_delete_user(target_username: String) -> void:
	if not is_admin:
		emit_signal("account_action_failed", "غير مسموح لك بالتعديل!")
		return
	var url = FIREBASE_DB_URL + "users/" + target_username + ".json"
	var admin_http = HTTPRequest.new()
	add_child(admin_http)
	admin_http.request_completed.connect(func(_r, rc, _h, _b):
		if is_instance_valid(admin_http):
			admin_http.queue_free()
		if rc == 200:
			emit_signal("account_action_success", "تم حذف الحساب " + target_username)
		else:
			emit_signal("account_action_failed", "فشل الحذف")
	)
	admin_http.request(url, [], HTTPClient.METHOD_DELETE)

func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var body_string = body.get_string_from_utf8()
	if response_code == 200:
		var response = JSON.parse_string(body_string)
		if response is Dictionary:
			var top_players = []
			for username in response.keys():
				var user_data = response[username]
				if user_data is Dictionary and user_data.has("score"):
					var clean_name = username.get_slice("/", username.get_slice_count("/") - 1)
					var raw_bytes = clean_name.to_utf8_buffer()
					var converted_name = raw_bytes.get_string_from_utf8()
					if converted_name == "":
						converted_name = username
						
					top_players.append({
						"player_name": converted_name, 
						"score": int(user_data["score"])
					})
			top_players.sort_custom(func(a, b): return a["score"] > b["score"])
			if top_players.size() > 10:
				top_players = top_players.slice(0, 10)
			emit_signal("leaderboard_loaded", top_players)
		elif response is Dictionary and response.has("id"):
			emit_signal("account_action_success", "تم إنشاء الحساب أونلاين!")
	else:
		emit_signal("account_action_failed", "خطأ في الاتصال بالسيرفر الأونلاين")

func _save_user_locally(username: String) -> void:
	var file = FileAccess.open(LOCAL_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(username)
		file.close()

func _load_saved_user() -> String:
	if not FileAccess.file_exists(LOCAL_SAVE_PATH):
		return ""
	var file = FileAccess.open(LOCAL_SAVE_PATH, FileAccess.READ)
	if file:
		var username = file.get_as_text().strip_edges()
		file.close()
		return username
	return ""

func _clear_saved_user() -> void:
	if FileAccess.file_exists(LOCAL_SAVE_PATH):
		DirAccess.remove_absolute(LOCAL_SAVE_PATH)

func logout() -> void:
	if current_user != "":
		save_player_score(Global.Score)
	current_user = ""
	is_admin = false
	_clear_saved_user()
	Global.current_user = ""
	Global.set_score(0)
	emit_signal("account_action_success", "تم تسجيل الخروج بنجاح!")
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.change_scene_to_file("res://SCENES/acount_system.tscn")

func login_with_google() -> void:
	oauth_server = TCPServer.new()
	var err = oauth_server.listen(8080, "127.0.0.1")
	if err != OK:
		emit_signal("account_action_failed", "فشل تشغيل سيرفر المصادقة المحلي")
		return

	var auth_url = "https://accounts.google.com/o/oauth2/v2/auth?" + \
		"client_id=" + GOOGLE_CLIENT_ID + \
		"&redirect_uri=" + REDIRECT_URI + \
		"&response_type=code" + \
		"&scope=email%20profile"
		
	OS.shell_open(auth_url)
	set_process(true)

func _process(_delta: float) -> void:
	if oauth_server and oauth_server.is_connection_available():
		var peer = oauth_server.take_connection()
		var request = peer.get_string(peer.get_available_bytes())
		
		if "code=" in request:
			var raw_code = request.get_slice("code=", 1).get_slice(" ", 0).get_slice("&", 0)
			var code = raw_code.uri_decode()
			
			var response_http = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<h2>Success! Return to the game now.</h2>"
			peer.put_data(response_http.to_utf8_buffer())
			
			oauth_server.stop()
			set_process(false)
			
			_exchange_code_for_token(code)

func _exchange_code_for_token(code: String) -> void:
	var url = "https://oauth2.googleapis.com/token"
	var body = "code=" + code.uri_encode() + \
		"&client_id=" + GOOGLE_CLIENT_ID + \
		"&client_secret=" + GOOGLE_CLIENT_SECRET + \
		"&redirect_uri=" + REDIRECT_URI + \
		"&grant_type=authorization_code"
		
	var token_http = HTTPRequest.new()
	add_child(token_http)
	token_http.request_completed.connect(func(_r, rc, _h, b):
		if is_instance_valid(token_http):
			token_http.queue_free()
		if rc == 200:
			var res = JSON.parse_string(b.get_string_from_utf8())
			var access_token = res.get("access_token", "")
			_get_google_user_info(access_token)
		else:
			emit_signal("account_action_failed", "فشل التحقق من حساب جوجل")
	)
	token_http.request(url, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST, body)

func _get_google_user_info(access_token: String) -> void:
	var url = "https://www.googleapis.com/oauth2/v2/userinfo"
	var headers = ["Authorization: Bearer " + access_token]
	var user_http = HTTPRequest.new()
	add_child(user_http)
	user_http.request_completed.connect(func(_r, rc, _h, b):
		if is_instance_valid(user_http):
			user_http.queue_free()
		if rc == 200:
			var user_data = JSON.parse_string(b.get_string_from_utf8())
			var google_name = user_data.get("name", "GoogleUser").replace(" ", "_").replace(".", "")
			current_user = google_name
			_save_user_locally(google_name)
			_register_google_user_in_firebase(google_name)
		else:
			emit_signal("account_action_failed", "فشل جلب بيانات حساب جوجل")
	)
	user_http.request(url, headers, HTTPClient.METHOD_GET)

func _register_google_user_in_firebase(username: String) -> void:
	var clean_username = username.strip_edges().replace("/", "")
	var url = FIREBASE_BASE_URL + clean_username + ".json"
	
	var user_data = {
		"is_admin": false,
		"password": "GOOGLE_AUTH_USER",
		"score": 0
	}
	var json_data = JSON.stringify(user_data)
	
	var save_http = HTTPRequest.new()
	add_child(save_http)
	save_http.request_completed.connect(func(_r, rc, _h, _b):
		if is_instance_valid(save_http):
			save_http.queue_free()
		if rc == 200:
			current_user = clean_username
			is_admin = false
			_save_user_locally(clean_username)
			Global.current_user = clean_username
			Global.set_score(0)
			
			emit_signal("account_action_success", "تم تسجيل الدخول بنجاح!")
			emit_signal("admin_status_checked", is_admin)
			await get_tree().create_timer(0.5).timeout
			var tree = Engine.get_main_loop() as SceneTree
			if tree:
				tree.change_scene_to_file("res://SCENES/MAIN MENU.tscn")
		else:
			emit_signal("account_action_failed", "فشل حفظ البيانات في قاعدة البيانات")
	)
	save_http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_PUT, json_data)

func _on_الغاء_pressed() -> void:
	var create_panel = get_node_or_null("CREATE")
	if create_panel:
		for child in create_panel.get_children():
			if child is LineEdit:
				child.text = ""
			elif child is RichTextLabel and child.name == "اسم المستخدم2":
				child.text = ""

func _on_الغاء2_pressed() -> void:
	var login_panel = get_node_or_null("LOGIN")
	if login_panel:
		for child in login_panel.get_children():
			if child is LineEdit:
				child.text = ""
			elif child is RichTextLabel and child.name == "الحالة":
				child.text = ""
