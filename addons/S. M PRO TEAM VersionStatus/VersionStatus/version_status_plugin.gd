@tool
extends EditorPlugin
const AUTOLOAD_NAME = "VersionStatus"
const AUTOLOAD_PATH = "res://addons/S. M PRO TEAM VersionStatus/VersionStatus/VersionStatus.gd"
const DATA_CONTROL_PATH = "res://addons/S. M PRO TEAM VersionStatus/VersionStatus/Data_Control.gd"
const CUSTOM_TYPE_NAME = "Version Status"
const CUSTOM_TYPE_BASE = "Control"
const CUSTOM_TYPE_ICON = "res://addons/S. M PRO TEAM VersionStatus/VersionStatus/texture/VersionStatusIcon.png"
const EXPORT_PRESETS_PATH := "res://export_presets.cfg"
var _last_version: String = ""
var _custom_type_registered: bool = false
var _inspector_plugin: EditorInspectorPlugin = null
func _enable_plugin():
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
func _disable_plugin():
	remove_autoload_singleton(AUTOLOAD_NAME)
func _enter_tree() -> void:
	_register_custom_type()
	_connect_inspector()
	_inspector_plugin = VSLInspectorPlugin.new()
	add_inspector_plugin(_inspector_plugin)
func _exit_tree() -> void:
	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
	_disconnect_inspector()
	_unregister_custom_type()
	_last_version = ""
func _connect_inspector() -> void:
	if not EditorInterface:
		return
	var inspector := EditorInterface.get_inspector()
	if inspector and not inspector.property_edited.is_connected(_on_inspector_property_edited):
		inspector.property_edited.connect(_on_inspector_property_edited)
func _disconnect_inspector() -> void:
	if not EditorInterface:
		return
	var inspector := EditorInterface.get_inspector()
	if inspector and inspector.property_edited.is_connected(_on_inspector_property_edited):
		inspector.property_edited.disconnect(_on_inspector_property_edited)
func _on_inspector_property_edited(property: String) -> void:
	if not property.begins_with("Your_game_version"):
		return
	var inspector := EditorInterface.get_inspector()
	if not inspector:
		return
	var edited_object := inspector.get_edited_object()
	if not edited_object:
		return
	var scr := edited_object.get_script()
	if not scr:
		return
	if scr.resource_path != DATA_CONTROL_PATH:
		return
	var new_version := ""
	if "Your_game_version" in edited_object:
		new_version = str(edited_object.Your_game_version).strip_edges()
	if new_version.is_empty():
		return
	if new_version == _last_version:
		return
	_last_version = new_version
	print("[VersionStatus] 📝 تم استقبال التعديل من Inspector: ", new_version)
	_sync_version_to_export_presets(new_version)
func _register_custom_type() -> void:
	if _custom_type_registered:
		return
	var script_resource := load(DATA_CONTROL_PATH)
	if not script_resource:
		push_warning("[VersionStatus] تعذّر تحميل Data_Control.gd — تأكد من المسار")
		return
	var icon_texture: Texture2D = null
	if ResourceLoader.exists(CUSTOM_TYPE_ICON):
		icon_texture = load(CUSTOM_TYPE_ICON)
	else:
		push_warning("[VersionStatus] لم يتم العثور على أيقونة — سيتم استخدام الأيقونة الافتراضية")
	add_custom_type(CUSTOM_TYPE_NAME, CUSTOM_TYPE_BASE, script_resource, icon_texture)
	_custom_type_registered = true
func _unregister_custom_type() -> void:
	if not _custom_type_registered:
		return
	remove_custom_type(CUSTOM_TYPE_NAME)
	_custom_type_registered = false
func _sync_version_to_export_presets(version: String) -> void:
	if version.is_empty():
		return
	if not FileAccess.file_exists(EXPORT_PRESETS_PATH):
		return
	var cfg := ConfigFile.new()
	if cfg.load(EXPORT_PRESETS_PATH) != OK:
		return
	var changed := false
	var build_code := _version_to_code(version)
	for section in cfg.get_sections():
		if not section.ends_with(".options"):
			continue
		if cfg.has_section_key(section, "version/name"):
			if str(cfg.get_value(section, "version/name")) != version:
				cfg.set_value(section, "version/name", version)
				changed = true
		if cfg.has_section_key(section, "version/code"):
			if int(cfg.get_value(section, "version/code")) != build_code:
				cfg.set_value(section, "version/code", build_code)
				changed = true
		if cfg.has_section_key(section, "version/code"):
			if cfg.has_section_key(section, "permissions/internet"):
				if bool(cfg.get_value(section, "permissions/internet")) != true:
					cfg.set_value(section, "permissions/internet", true)
					changed = true
			else:
				cfg.set_value(section, "permissions/internet", true)
				changed = true
		if cfg.has_section_key(section, "application/short_version"):
			if str(cfg.get_value(section, "application/short_version")) != version:
				cfg.set_value(section, "application/short_version", version)
				changed = true
		if cfg.has_section_key(section, "application/version"):
			var build_str := str(build_code)
			if str(cfg.get_value(section, "application/version")) != build_str:
				cfg.set_value(section, "application/version", build_str)
				changed = true
		if cfg.has_section_key(section, "application/product_version"):
			if str(cfg.get_value(section, "application/product_version")) != version:
				cfg.set_value(section, "application/product_version", version)
				changed = true
		if cfg.has_section_key(section, "application/file_version"):
			if str(cfg.get_value(section, "application/file_version")) != version:
				cfg.set_value(section, "application/file_version", version)
				changed = true
	if changed:
		cfg.save(EXPORT_PRESETS_PATH)
		print("[VersionStatus] ✅ مزامنة الإصدار: ", version, "  |  build_code = ", build_code, "  |  internet = true")
		if EditorInterface:
			var fs := EditorInterface.get_resource_filesystem()
			if fs:
				fs.scan()
func _version_to_code(v: String) -> int:
	var parts := v.split(".")
	var nums := [0, 0, 0]
	for i in range(min(parts.size(), 3)):
		var digits := ""
		for c in parts[i]:
			if c >= "0" and c <= "9":
				digits += c
			else:
				break
		if not digits.is_empty():
			nums[i] = int(digits)
	nums[0] = clampi(nums[0], 0, 99)
	nums[1] = clampi(nums[1], 0, 99)
	nums[2] = clampi(nums[2], 0, 99)
	return nums[0] * 10000 + nums[1] * 100 + nums[2]
class VSLInspectorPlugin extends EditorInspectorPlugin:
	func _can_handle(object: Object) -> bool:
		return "url" in object
	func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
		if name == "url":
			var container = HBoxContainer.new()
			var open_btn = Button.new()
			open_btn.text = "فتح في المتصفح"
			open_btn.pressed.connect(func(): OS.shell_open(object.url))
			var copy_btn = Button.new()
			copy_btn.text = "نسخ الرابط"
			copy_btn.pressed.connect(func():
				DisplayServer.clipboard_set(object.url)
				print("تم نسخ الرابط: ", object.url))
			container.add_child(open_btn)
			container.add_child(copy_btn)
			add_custom_control(container)
			return false
		return false