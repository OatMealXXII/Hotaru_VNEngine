class_name Localization
extends Node

## Handles localization and translation of text
## Supports CSV/JSON import/export and runtime language switching

signal language_changed(lang_code: String)
signal translation_missing(key: String, lang_code: String)

# Current language
var current_language: String = "en"
var fallback_language: String = "en"

# Translation data
var translations: Dictionary = {}

# Available languages
var available_languages: Array = ["en"]

func _ready():
	load_translations()

func set_language(lang_code: String) -> void:
	"""Set the current language"""
	if lang_code in available_languages:
		current_language = lang_code
		language_changed.emit(lang_code)
	else:
		push_warning("Language not available: " + lang_code)

func translate(text: String) -> String:
	"""Translate text using current language"""
	# If text is a translation key (starts with #)
	if text.begins_with("#"):
		var key = text.substr(1)
		return get_translation(key, current_language)
	
	# Otherwise return text as-is
	return text

func get_translation(key: String, lang_code: String = "") -> String:
	"""Get translation for a specific key and language"""
	if lang_code == "":
		lang_code = current_language
	
	# Try current language first
	if translations.has(lang_code) and translations[lang_code].has(key):
		return translations[lang_code][key]
	
	# Try fallback language
	if translations.has(fallback_language) and translations[fallback_language].has(key):
		return translations[fallback_language][key]
	
	# Translation missing
	translation_missing.emit(key, lang_code)
	return "[MISSING: " + key + "]"

func load_translations() -> void:
	"""Load translations from files"""
	var translation_dir = "res://addons/gn_vn/localization/"
	
	if not DirAccess.dir_exists_absolute(translation_dir):
		# Create default translations
		create_default_translations()
		return
	
	var dir = DirAccess.open(translation_dir)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".json"):
			var lang_code = file_name.get_basename()
			load_language_file(translation_dir + file_name, lang_code)
		file_name = dir.get_next()

func load_language_file(file_path: String, lang_code: String) -> void:
	"""Load translations from a JSON file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open translation file: " + file_path)
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse translation file: " + json.get_error_message())
		return
	
	translations[lang_code] = json.data
	available_languages.append(lang_code)

func create_default_translations() -> void:
	"""Create default English translations"""
	translations["en"] = {
		"continue": "Continue",
		"save": "Save",
		"load": "Load",
		"settings": "Settings",
		"quit": "Quit",
		"yes": "Yes",
		"no": "No",
		"ok": "OK",
		"cancel": "Cancel"
	}

func export_translations(lang_code: String, file_path: String) -> bool:
	"""Export translations to a JSON file"""
	if not translations.has(lang_code):
		return false
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return false
	
	var json_string = JSON.stringify(translations[lang_code], "\t")
	file.store_string(json_string)
	file.close()
	
	return true

func import_translations(file_path: String, lang_code: String) -> bool:
	"""Import translations from a JSON file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return false
	
	translations[lang_code] = json.data
	if not lang_code in available_languages:
		available_languages.append(lang_code)
	
	return true

func export_to_csv(file_path: String) -> bool:
	"""Export all translations to CSV format"""
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return false
	
	# Get all unique keys
	var all_keys = []
	for lang_code in translations.keys():
		for key in translations[lang_code].keys():
			if not key in all_keys:
				all_keys.append(key)
	
	# Write header
	var header = "Key"
	for lang_code in available_languages:
		header += "," + lang_code
	file.store_line(header)
	
	# Write data rows
	for key in all_keys:
		var row = key
		for lang_code in available_languages:
			var translation = get_translation(key, lang_code)
			# Escape commas and quotes in CSV
			translation = translation.replace("\"", "\"\"")
			if "," in translation or "\"" in translation:
				translation = "\"" + translation + "\""
			row += "," + translation
		file.store_line(row)
	
	file.close()
	return true

func import_from_csv(file_path: String) -> bool:
	"""Import translations from CSV format"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var lines = file.get_as_text().split("\n")
	file.close()
	
	if lines.size() < 2:
		return false
	
	# Parse header
	var header = lines[0].split(",")
	var languages = []
	for i in range(1, header.size()):
		languages.append(header[i])
	
	# Parse data rows
	for i in range(1, lines.size()):
		if lines[i].strip_edges() == "":
			continue
		
		var row = parse_csv_line(lines[i])
		if row.size() < 2:
			continue
		
		var key = row[0]
		for j in range(1, min(row.size(), languages.size() + 1)):
			var lang_code = languages[j - 1]
			var translation = row[j]
			
			if not translations.has(lang_code):
				translations[lang_code] = {}
			
			translations[lang_code][key] = translation
			
			if not lang_code in available_languages:
				available_languages.append(lang_code)
	
	return true

func parse_csv_line(line: String) -> Array:
	"""Parse a CSV line handling quoted fields"""
	var result = []
	var current_field = ""
	var in_quotes = false
	var i = 0
	
	while i < line.length():
		var char = line[i]
		
		if char == "\"":
			if in_quotes and i + 1 < line.length() and line[i + 1] == "\"":
				# Escaped quote
				current_field += "\""
				i += 2
				continue
			else:
				# Toggle quote state
				in_quotes = !in_quotes
		elif char == "," and not in_quotes:
			# Field separator
			result.append(current_field)
			current_field = ""
		else:
			current_field += char
		
		i += 1
	
	# Add last field
	result.append(current_field)
	return result

func get_available_languages() -> Array:
	"""Get list of available languages"""
	return available_languages.duplicate()

func get_current_language() -> String:
	"""Get current language code"""
	return current_language
