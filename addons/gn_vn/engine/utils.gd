class_name Utils
extends RefCounted

## Utility functions for GN_VN
## Provides common helper functions and constants

# Text processing constants
const RUBY_PATTERN = "\\[ruby=([^\\]]+)\\]([^\\[]+)\\[/ruby\\]"
const COLOR_PATTERN = "\\{color=([^\\}]+)\\}([^\\{]+)\\{/color\\}"
const BOLD_PATTERN = "\\*\\*([^\\*]+)\\*\\*"
const ITALIC_PATTERN = "\\*([^\\*]+)\\*"

# File system utilities
static func ensure_directory_exists(path: String) -> bool:
	##Ensure a directory exists, creating it if necessary##
	if DirAccess.dir_exists_absolute(path):
		return true
	
	var dir = DirAccess.open("res://")
	if dir:
		return dir.make_dir_recursive(path) == OK
	
	return false

static func get_safe_filename(filename: String) -> String:
	##Convert a string to a safe filename##
	var safe_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
	var result = ""
	
	for char in filename:
		if safe_chars.contains(char):
			result += char
		else:
			result += "_"
	
	return result

# Text processing utilities
static func process_text_formatting(text: String) -> String:
	##Process all text formatting in a string##
	text = process_ruby_text(text)
	text = process_color_formatting(text)
	text = process_bold_formatting(text)
	text = process_italic_formatting(text)
	return text

static func process_ruby_text(text: String) -> String:
	##Process ruby/furigana annotations##
	var regex = RegEx.new()
	regex.compile(RUBY_PATTERN)
	return regex.sub(text, "[font_size=12]$1[/font_size][font_size=8]$2[/font_size]")

static func process_color_formatting(text: String) -> String:
	##Process color formatting##
	var regex = RegEx.new()
	regex.compile(COLOR_PATTERN)
	return regex.sub(text, "[color=$1]$2[/color]")

static func process_bold_formatting(text: String) -> String:
	##Process bold formatting##
	var regex = RegEx.new()
	regex.compile(BOLD_PATTERN)
	return regex.sub(text, "[b]$1[/b]")

static func process_italic_formatting(text: String) -> String:
	##Process italic formatting##
	var regex = RegEx.new()
	regex.compile(ITALIC_PATTERN)
	return regex.sub(text, "[i]$1[/i]")

# Math utilities
static func lerp_color(a: Color, b: Color, t: float) -> Color:
	##Linear interpolation between two colors##
	return Color(
		lerpf(a.r, b.r, t),
		lerpf(a.g, b.g, t),
		lerpf(a.b, b.b, t),
		lerpf(a.a, b.a, t)
	)

static func clamp_vector2(value: Vector2, min_val: Vector2, max_val: Vector2) -> Vector2:
	##Clamp a Vector2 between min and max values##
	return Vector2(
		clampf(value.x, min_val.x, max_val.x),
		clampf(value.y, min_val.y, max_val.y)
	)

# Validation utilities
static func is_valid_node_id(node_id: String) -> bool:
	##Check if a node ID is valid##
	if node_id.is_empty():
		return false
	
	# Check for invalid characters
	var invalid_chars = " \t\n\r\"'`~!@#$%^&*()+={}[]|\\:;<>?/"
	for char in invalid_chars:
		if node_id.contains(char):
			return false
	
	return true

static func is_valid_expression(expression: String) -> bool:
	##Check if an expression is valid (basic validation)##
	if expression.is_empty():
		return false
	
	# Check for balanced parentheses
	var open_count = 0
	for char in expression:
		if char == "(":
			open_count += 1
		elif char == ")":
			open_count -= 1
			if open_count < 0:
				return false
	
	return open_count == 0

# Debug utilities
static func debug_print(message: String, level: int = 0) -> void:
	##Print debug message with level##
	var prefix = ""
	match level:
		0: prefix = "[INFO]"
		1: prefix = "[WARNING]"
		2: prefix = "[ERROR]"
	
	print(prefix + " GN_VN: " + message)

static func format_time(seconds: float) -> String:
	##Format time in seconds to HH:MM:SS format##
	var hours = int(seconds) / 3600
	var minutes = (int(seconds) % 3600) / 60
	var secs = int(seconds) % 60
	
	return "%02d:%02d:%02d" % [hours, minutes, secs]

# Resource utilities
static func load_resource_safe(path: String) -> Resource:
	##Safely load a resource, returning null if it fails##
	if not FileAccess.file_exists(path):
		return null
	
	return load(path)

static func save_resource_safe(resource: Resource, path: String) -> bool:
	##Safely save a resource, returning success status##
	if not resource:
		return false
	
	return ResourceSaver.save(resource, path) == OK
