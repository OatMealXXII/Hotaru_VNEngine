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
	# Create menu bar
	menu_bar = HBoxContainer.new()
	menu_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	menu_bar.custom_minimum_size = Vector2(0, 40)
	add_child(menu_bar)
	
	# Create buttons
	save_button = create_menu_button("Save")
	load_button = create_menu_button("Load")
	settings_button = create_menu_button("Settings")
	quit_button = create_menu_button("Quit")
	
	menu_bar.add_child(save_button)
	menu_bar.add_child(load_button)
	menu_bar.add_child(settings_button)
	menu_bar.add_child(quit_button)
	
	# Create settings panel
	setup_settings_panel()

func create_menu_button(text: String) -> Button:
	"""Create a menu button"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(80, 30)
	
	# Style the button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	style_normal.corner_radius_top_left = 5
	style_normal.corner_radius_top_right = 5
	style_normal.corner_radius_bottom_left = 5
	style_normal.corner_radius_bottom_right = 5
	button.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.3, 0.3, 0.3, 0.9)
	style_hover.corner_radius_top_left = 5
	style_hover.corner_radius_top_right = 5
	style_hover.corner_radius_bottom_left = 5
	style_hover.corner_radius_bottom_right = 5
	button.add_theme_stylebox_override("hover", style_hover)
	
	return button

func setup_settings_panel():
	"""Setup the settings panel"""
	settings_panel = Control.new()
	settings_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	settings_panel.custom_minimum_size = Vector2(300, 200)
	settings_panel.visible = false
	add_child(settings_panel)
	
	# Create settings background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.9)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_panel.add_child(bg)
	
	# Create settings content
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.custom_minimum_size = Vector2(280, 180)
	settings_panel.add_child(vbox)
	
	# Text speed setting
	var text_speed_label = Label.new()
	text_speed_label.text = "Text Speed"
	vbox.add_child(text_speed_label)
	
	text_speed_slider = HSlider.new()
	text_speed_slider.min_value = 10.0
	text_speed_slider.max_value = 100.0
	text_speed_slider.value = 50.0
	vbox.add_child(text_speed_slider)
	
	# Auto advance setting
	auto_advance_toggle = CheckBox.new()
	auto_advance_toggle.text = "Auto Advance"
	auto_advance_toggle.button_pressed = true
	vbox.add_child(auto_advance_toggle)
	
	# Volume setting
	var volume_label = Label.new()
	volume_label.text = "Volume"
	vbox.add_child(volume_label)
	
	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.value = 0.8
	vbox.add_child(volume_slider)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_on_settings_close)
	vbox.add_child(close_button)

func setup_signals():
	"""Setup signal connections"""
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_save_pressed():
	"""Handle save button press"""
	# For now, save to slot 0
	save_requested.emit(0)

func _on_load_pressed():
	"""Handle load button press"""
	# For now, load from slot 0
	load_requested.emit(0)

func _on_settings_pressed():
	"""Handle settings button press"""
	settings_panel.visible = !settings_panel.visible
	if settings_panel.visible:
		settings_requested.emit()

func _on_quit_pressed():
	"""Handle quit button press"""
	quit_requested.emit()

func _on_settings_close():
	"""Close settings panel"""
	settings_panel.visible = false

func get_text_speed() -> float:
	"""Get current text speed setting"""
	return text_speed_slider.value

func get_auto_advance() -> bool:
	"""Get auto advance setting"""
	return auto_advance_toggle.button_pressed

func get_volume() -> float:
	"""Get volume setting"""
	return volume_slider.value

func set_text_speed(speed: float) -> void:
	"""Set text speed"""
	text_speed_slider.value = speed

func set_auto_advance(enabled: bool) -> void:
	"""Set auto advance"""
	auto_advance_toggle.button_pressed = enabled

func set_volume(volume: float) -> void:
	"""Set volume"""
	volume_slider.value = volume

func show_save_menu() -> void:
	"""Show save menu (could be expanded)"""
	# For now, just trigger save
	save_requested.emit(0)

func show_load_menu() -> void:
	"""Show load menu (could be expanded)"""
	# For now, just trigger load
	load_requested.emit(0)
