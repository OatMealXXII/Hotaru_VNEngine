class_name ChoiceBox
extends Control

## UI component for presenting choices to the player
## Supports keyboard navigation and touch input

signal choice_selected(choice_index: int)

# UI elements
var choice_container: VBoxContainer
var choice_buttons: Array = []

# State
var current_choices: Array = []
var selected_index: int = 0

func _ready():
	setup_ui()
	setup_input()

func setup_ui():
	# Create main container
	choice_container = VBoxContainer.new()
	choice_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	choice_container.custom_minimum_size = Vector2(400, 200)
	add_child(choice_container)
	
	# Style the choice box
	apply_default_styling()

func setup_input():
	# Enable input processing
	set_process_input(true)

func apply_default_styling():
	##Apply default styling to the choice box##
	# Set background
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.9)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	add_theme_stylebox_override("panel", style_box)

func present_choices(choices: Array) -> void:
	## Present choices to the player
	current_choices = choices
	selected_index = 0
	
	# Clear existing buttons
	clear_choices()
	
	# Create choice buttons
	for i in range(choices.size()):
		var choice = choices[i]
		var button = create_choice_button(i, choice)
		choice_container.add_child(button)
		choice_buttons.append(button)
	
	# Show the choice box
	visible = true
	
	# Focus first button
	if choice_buttons.size() > 0:
		choice_buttons[0].grab_focus()

func create_choice_button(index: int, choice: Dictionary) -> Button:
	## Create a choice button
	var button = Button.new()
	button.text = choice.get("text", "")
	button.custom_minimum_size = Vector2(350, 40)
	
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
	
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.1, 0.1, 0.1, 1.0)
	style_pressed.corner_radius_top_left = 5
	style_pressed.corner_radius_top_right = 5
	style_pressed.corner_radius_bottom_left = 5
	style_pressed.corner_radius_bottom_right = 5
	button.add_theme_stylebox_override("pressed", style_pressed)
	
	# Connect button signal
	button.pressed.connect(_on_choice_selected.bind(index))
	
	return button

func clear_choices() -> void:
	## Clear all choice buttons
	for button in choice_buttons:
		button.queue_free()
	choice_buttons.clear()

func _input(event: InputEvent):
	## Handle input events
	if not visible:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				select_previous_choice()
			KEY_DOWN:
				select_next_choice()
			KEY_ENTER, KEY_SPACE:
				confirm_choice()
			KEY_ESCAPE:
				# Could add cancel functionality here
				pass

func select_previous_choice() -> void:
	## Select the previous choice
	if choice_buttons.size() == 0:
		return
	
	selected_index = (selected_index - 1) % choice_buttons.size()
	update_selection()

func select_next_choice() -> void:
	## Select the next choice
	if choice_buttons.size() == 0:
		return
	
	selected_index = (selected_index + 1) % choice_buttons.size()
	update_selection()

func update_selection() -> void:
	## Update visual selection
	for i in range(choice_buttons.size()):
		var button = choice_buttons[i]
		if i == selected_index:
			button.grab_focus()
		else:
			button.release_focus()

func confirm_choice() -> void:
	## Confirm the selected choice
	if selected_index >= 0 and selected_index < choice_buttons.size():
		choice_selected.emit(selected_index)

func _on_choice_selected(index: int) -> void:
	## Handle choice button press
	choice_selected.emit(index)

func hide_choices() -> void:
	## Hide the choice box
	visible = false
	clear_choices()

func get_choice_count() -> int:
	## Get the number of current choices
	return current_choices.size()

func get_choice_text(index: int) -> String:
	## Get the text of a specific choice
	if index >= 0 and index < current_choices.size():
		return current_choices[index].get("text", "")
	return ""
