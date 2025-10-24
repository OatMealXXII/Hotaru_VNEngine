class_name VNHUD
extends Control

## Main HUD for the Visual Novel
## Provides save/load, settings, and other game controls

signal save_requested(slot: int)
signal load_requested(slot: int)
signal settings_requested()
signal quit_requested()

# UI elements
var menu_bar: HBoxContainer
var save_button: Button
var load_button: Button
var settings_button: Button
var quit_button: Button

# Settings panel
var settings_panel: Control
var text_speed_slider: HSlider
var auto_advance_toggle: CheckBox
var volume_slider: HSlider

func _ready():
	setup_ui()
	setup_signals()

func setup_ui():
	# Get references to existing buttons from the scene
	save_button = get_node("HBoxContainer/SaveButton")
	load_button = get_node("HBoxContainer/LoadButton")
	settings_button = get_node("HBoxContainer/SettingsButton")
	quit_button = get_node("HBoxContainer/QuitButton")
	
	# Create settings panel
	setup_settings_panel()


func setup_settings_panel():
	## Setup the settings panel
	settings_panel = Control.new()
	# Set position manually to ensure it's visible
	settings_panel.position = Vector2(1020, 80) # Right side of 1280x720 screen
	settings_panel.size = Vector2(240, 240)
	settings_panel.custom_minimum_size = Vector2(240, 240)
	settings_panel.visible = false
	add_child(settings_panel)
	
	# Create settings background with proper styling
	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.15, 0.98) # Match main UI background
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_panel.add_child(bg)
	
	# Add border to make it look more integrated
	var border = StyleBoxFlat.new()
	border.bg_color = Color(0.25, 0.25, 0.25, 1.0)
	border.border_width_left = 1
	border.border_width_right = 1
	border.border_width_top = 1
	border.border_width_bottom = 1
	border.corner_radius_top_left = 6
	border.corner_radius_top_right = 6
	border.corner_radius_bottom_left = 6
	border.corner_radius_bottom_right = 6
	settings_panel.add_theme_stylebox_override("panel", border)
	
	# Create settings content with proper padding
	var padding = MarginContainer.new()
	padding.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	padding.add_theme_constant_override("margin_left", 16)
	padding.add_theme_constant_override("margin_right", 16)
	padding.add_theme_constant_override("margin_top", 16)
	padding.add_theme_constant_override("margin_bottom", 16)
	settings_panel.add_child(padding)
	
	# Create main VBoxContainer
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	padding.add_child(vbox)
	
	# Text speed setting
	var text_speed_label = Label.new()
	text_speed_label.text = "Text Speed"
	text_speed_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(text_speed_label)
	
	text_speed_slider = HSlider.new()
	text_speed_slider.min_value = 10.0
	text_speed_slider.max_value = 100.0
	text_speed_slider.value = 50.0
	text_speed_slider.value_changed.connect(_on_text_speed_changed)
	
	# Style the slider
	var slider_style = StyleBoxFlat.new()
	slider_style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	text_speed_slider.add_theme_stylebox_override("slider", slider_style)
	
	var grabber_style = StyleBoxFlat.new()
	grabber_style.bg_color = Color(0.5, 0.5, 0.5, 1.0)
	text_speed_slider.add_theme_stylebox_override("grabber", grabber_style)
	
	vbox.add_child(text_speed_slider)
	
	# Auto advance setting
	auto_advance_toggle = CheckBox.new()
	auto_advance_toggle.text = "Auto Advance"
	auto_advance_toggle.button_pressed = false # Default to manual advance
	auto_advance_toggle.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(auto_advance_toggle)
	
	# Volume setting
	var volume_label = Label.new()
	volume_label.text = "Volume"
	volume_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(volume_label)
	
	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.value = 0.8
	
	# Style the volume slider
	var volume_slider_style = StyleBoxFlat.new()
	volume_slider_style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	volume_slider.add_theme_stylebox_override("slider", volume_slider_style)
	
	var volume_grabber_style = StyleBoxFlat.new()
	volume_grabber_style.bg_color = Color(0.5, 0.5, 0.5, 1.0)
	volume_slider.add_theme_stylebox_override("grabber", volume_grabber_style)
	
	vbox.add_child(volume_slider)
	
	# Close button with proper styling
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_on_settings_close)
	
	# Style the close button
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.3, 0.3, 0.3, 1.0)
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.corner_radius_bottom_right = 4
	close_button.add_theme_stylebox_override("normal", button_style)
	
	var button_hover_style = StyleBoxFlat.new()
	button_hover_style.bg_color = Color(0.4, 0.4, 0.4, 1.0)
	button_hover_style.corner_radius_top_left = 4
	button_hover_style.corner_radius_top_right = 4
	button_hover_style.corner_radius_bottom_left = 4
	button_hover_style.corner_radius_bottom_right = 4
	close_button.add_theme_stylebox_override("hover", button_hover_style)
	
	vbox.add_child(close_button)

func setup_signals():
	## Setup signal connections
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_save_pressed():
	## Handle save button press
	# For now, save to slot 0
	save_requested.emit(0)

func _on_load_pressed():
	## Handle load button press
	# For now, load from slot 0
	load_requested.emit(0)

func _on_settings_pressed():
	## Handle settings button press
	settings_panel.visible = !settings_panel.visible
	if settings_panel.visible:
		settings_requested.emit()

func _on_quit_pressed():
	## Handle quit button press
	quit_requested.emit()

func _on_settings_close():
	## Close settings panel
	settings_panel.visible = false

func _on_text_speed_changed(value: float):
	## Handle text speed slider change
	# Emit signal to update text speed in the dialogue system
	settings_requested.emit()

func get_text_speed() -> float:
	## Get current text speed setting
	return text_speed_slider.value

func get_auto_advance() -> bool:
	## Get auto advance setting
	return auto_advance_toggle.button_pressed

func get_volume() -> float:
	## Get volume setting
	return volume_slider.value

func set_text_speed(speed: float) -> void:
	## Set text speed
	text_speed_slider.value = speed

func set_auto_advance(enabled: bool) -> void:
	##Set auto advance
	auto_advance_toggle.button_pressed = enabled

func set_volume(volume: float) -> void:
	##Set volume##
	volume_slider.value = volume

func show_save_menu() -> void:
	##Show save menu (could be expanded)##
	# For now, just trigger save
	save_requested.emit(0)

func show_load_menu() -> void:
	##Show load menu (could be expanded)##
	# For now, just trigger load
	load_requested.emit(0)
