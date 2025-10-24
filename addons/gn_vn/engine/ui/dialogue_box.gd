class_name DialogueBox
extends Control

## UI component for displaying dialogue text
## Supports rich text formatting, character names, and animations

signal text_finished()
signal text_clicked()

@export var text_speed: float = 50.0  # Characters per second
@export var auto_advance_delay: float = 2.0
@export var enable_click_to_continue: bool = true

# UI elements
var name_label: Label
var text_label: RichTextLabel
var continue_indicator: Control

# State
var is_typing: bool = false
var current_text: String = ""
var typing_timer: float = 0.0

func _ready():
	setup_ui()
	setup_signals()

func setup_ui():
	# Create UI elements
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)
	
	# Character name label
	name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vbox.add_child(name_label)
	
	# Dialogue text
	text_label = RichTextLabel.new()
	text_label.name = "TextLabel"
	text_label.fit_content = true
	text_label.scroll_active = false
	text_label.bbcode_enabled = true
	vbox.add_child(text_label)
	
	# Continue indicator
	continue_indicator = Control.new()
	continue_indicator.name = "ContinueIndicator"
	continue_indicator.custom_minimum_size = Vector2(20, 20)
	vbox.add_child(continue_indicator)
	
	# Style the UI
	apply_default_styling()

func setup_signals():
	# Connect input events
	gui_input.connect(_on_gui_input)
	text_label.meta_clicked.connect(_on_meta_clicked)

func apply_default_styling():
	"""Apply default styling to the dialogue box"""
	# Set background
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.8)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	add_theme_stylebox_override("panel", style_box)
	
	# Style name label
	var name_style = Label.new().get_theme_font("font")
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Style text label
	text_label.add_theme_font_size_override("normal_font_size", 16)
	text_label.add_theme_color_override("default_color", Color.WHITE)

func show_text(character_id: String, text: String, metadata: Dictionary = {}) -> void:
	"""Display text for a character"""
	# Update character name
	if character_id != "":
		name_label.text = character_id
		name_label.visible = true
	else:
		name_label.visible = false
	
	# Process text formatting
	text = process_text_formatting(text, metadata)
	
	# Start typing animation
	start_typing(text)

func process_text_formatting(text: String, metadata: Dictionary) -> String:
	"""Process text formatting and BBCode"""
	# Handle ruby/furigana text
	text = process_ruby_text(text)
	
	# Handle color formatting
	text = process_color_formatting(text)
	
	# Handle other BBCode
	text = process_bbcode(text)
	
	return text

func process_ruby_text(text: String) -> String:
	"""Process ruby/furigana annotations"""
	# Convert [ruby=base]reading[/ruby] to BBCode
	var regex = RegEx.new()
	regex.compile("\\[ruby=([^\\]]+)\\]([^\\[]+)\\[/ruby\\]")
	text = regex.sub(text, "[font_size=12]$1[/font_size][font_size=8]$2[/font_size]")
	return text

func process_color_formatting(text: String) -> String:
	"""Process color formatting"""
	# Convert {color=red}text{/color} to BBCode
	var regex = RegEx.new()
	regex.compile("\\{color=([^\\}]+)\\}([^\\{]+)\\{/color\\}")
	text = regex.sub(text, "[color=$1]$2[/color]")
	return text

func process_bbcode(text: String) -> String:
	"""Process BBCode formatting"""
	# Convert **bold** to [b]bold[/b]
	text = text.replace("**", "[b]").replace("**", "[/b]")
	
	# Convert *italic* to [i]italic[/i]
	text = text.replace("*", "[i]").replace("*", "[/i]")
	
	return text

func start_typing(text: String) -> void:
	"""Start typing animation"""
	current_text = text
	is_typing = true
	typing_timer = 0.0
	text_label.text = ""
	continue_indicator.visible = false

func _process(delta):
	if is_typing:
		typing_timer += delta
		var chars_to_show = int(typing_timer * text_speed)
		
		if chars_to_show >= current_text.length():
			# Typing finished
			text_label.text = current_text
			is_typing = false
			typing_timer = 0.0
			on_text_finished()
		else:
			# Show partial text
			text_label.text = current_text.substr(0, chars_to_show)

func on_text_finished() -> void:
	"""Called when text typing is finished"""
	continue_indicator.visible = true
	text_finished.emit()
	
	# Auto-advance after delay
	if auto_advance_delay > 0:
		await get_tree().create_timer(auto_advance_delay).timeout
		if not is_typing:
			text_clicked.emit()

func skip_typing() -> void:
	"""Skip typing animation and show full text"""
	if is_typing:
		is_typing = false
		text_label.text = current_text
		on_text_finished()

func _on_gui_input(event: InputEvent):
	"""Handle input events"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_typing:
				skip_typing()
			else:
				text_clicked.emit()

func _on_meta_clicked(meta):
	"""Handle meta clicks (links, etc.)"""
	# Emit signal for external handling
	meta_clicked.emit(meta)

func set_text_speed(speed: float) -> void:
	"""Set text typing speed"""
	text_speed = speed

func set_auto_advance_delay(delay: float) -> void:
	"""Set auto-advance delay"""
	auto_advance_delay = delay

func clear() -> void:
	"""Clear the dialogue box"""
	name_label.text = ""
	text_label.text = ""
	continue_indicator.visible = false
	is_typing = false
