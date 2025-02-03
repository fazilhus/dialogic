@tool
class_name DialogicSettings
extends Object

static var _settings : Dictionary = {}

static var default_settings_path : String = "res://dialogic-settings.json"
static var settings_path : String = ""

static func init():
	if ProjectSettings.has_setting("dialogic/settings_file"):
		settings_path = ProjectSettings.get_setting("dialogic/settings_file")
	else:
		ProjectSettings.set_setting("dialogic/settings_file", default_settings_path)
		DialogicSettings.save()
		settings_path = default_settings_path

	if !FileAccess.file_exists(settings_path):
		var file = FileAccess.open(settings_path, FileAccess.WRITE)
		var json = JSON.new()
		file.store_string(json.stringify({}))
		file.close()

	var file = FileAccess.open(settings_path, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error != OK:
		print("Invalid JSON")
		return
	
	_settings = json.data
	file.close()

static func clear(name: String) -> void:
	_settings.erase(name)

static func save() -> void:
	var file = FileAccess.open(settings_path, FileAccess.WRITE)
	var json = JSON.new()
	file.store_string(json.stringify(_settings, "\t"))
	file.close()

static func has_setting(name: String) -> bool:
	var res = get_setting(name)
	return res != null

static func get_setting(name: String, default_value: Variant = null, print: bool = false) -> Variant:
	var _v = _settings.get(name)
	if print:
		print(name, "\n\n", _v, "\n\n", _settings, '\n')
	return _v if _v != null else default_value


static func set_setting(name: String, value: Variant) -> void:
	_settings[name] = value

static func globalize_path(name: String) -> String:
	return DialogicSettings.globalize_path(name)

static func _parse_setting(name: String) -> PackedStringArray:
	return name.split("/")

static func import_from_project() -> void:
	for prop in ProjectSettings.get_property_list():
		if prop.name.begins_with("dialogic") and !prop.name.contains("settings_file"):
			_settings[prop.name] = ProjectSettings.get_setting(prop.name)
			ProjectSettings.clear(prop.name)
	ProjectSettings.save()
	save()
