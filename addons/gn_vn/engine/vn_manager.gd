class_name VNManager
extends Node

## Main Visual Novel Manager - Singleton that handles all VN operations
## Provides deterministic saves, rollback, and story execution

signal story_started(story_title: String)
signal story_ended()
signal text_shown(character_id: String, text: String, metadata: Dictionary)
signal choice_presented(choices: Array)
signal choice_made(choice_index: int, metadata: Dictionary)
signal node_changed(node_id: String)
signal save_created(slot: int)
signal save_loaded(slot: int)

# Story state
var current_story: StoryResource
var current_node_id: String = ""
var story_variables: Dictionary = {}
var call_stack: Array = []

# Rollback system
var rollback_buffer: Array = []
var max_rollback_steps: int = 1000
var current_step: int = 0

# Save system
var save_system: SaveSystem
var auto_save_slot: int = -1

# UI references
var dialogue_box: Control
var choice_box: Control
var vn_hud: Control

# Audio manager
var audio_manager: AudioManager

# Localization
var localization: Localization

# Random seed for deterministic behavior
var random_seed: int = 0

func _ready():
	# Initialize subsystems
	save_system = SaveSystem.new()
	add_child(save_system)
	
	audio_manager = AudioManager.new()
	add_child(audio_manager)
	
	localization = Localization.new()
	add_child(localization)
	
	# Set up UI references
	setup_ui()
	
	# Initialize random seed
	randomize_seed()

func setup_ui():
	# Load scenes
	var dialogue_scene = load("res://addons/gn_vn/engine/ui/dialogue_box.tscn")
	var choice_scene = load("res://addons/gn_vn/engine/ui/choice_box.tscn")
	var hud_scene = load("res://addons/gn_vn/engine/ui/vn_hud.tscn")

	# Prefer UI nodes that are part of the current scene (so editor/mockups in that scene are used)
	var current_scene = get_tree().get_current_scene()
	if current_scene:
		dialogue_box = current_scene.get_node_or_null("DialogueBox")
		choice_box = current_scene.get_node_or_null("ChoiceBox")
		vn_hud = current_scene.get_node_or_null("VNHUD")

	# If still not found, search the entire scene tree for existing instances
	if not dialogue_box:
		dialogue_box = get_tree().get_root().find_node("DialogueBox", true, false)
	if not choice_box:
		choice_box = get_tree().get_root().find_node("ChoiceBox", true, false)
	if not vn_hud:
		vn_hud = get_tree().get_root().find_node("VNHUD", true, false)

	# Instantiate missing UI and add them to the current scene when possible
	if not dialogue_box:
		dialogue_box = dialogue_scene.instantiate()
		dialogue_box.name = "DialogueBox"
		if current_scene:
			current_scene.add_child(dialogue_box)
		else:
			add_child(dialogue_box)

	if not choice_box:
		choice_box = choice_scene.instantiate()
		choice_box.name = "ChoiceBox"
		if current_scene:
			current_scene.add_child(choice_box)
		else:
			add_child(choice_box)

	if not vn_hud:
		vn_hud = hud_scene.instantiate()
		vn_hud.name = "VNHUD"
		if current_scene:
			current_scene.add_child(vn_hud)
		else:
			add_child(vn_hud)

	# Remove duplicate UI instances (keep the one we selected)
	var root = get_tree().get_root()
	if dialogue_box:
		_collect_and_free_duplicates(root, dialogue_box, "DialogueBox")
		# Ensure the selected instance is on top among its siblings
		if dialogue_box.has_method("raise"):
			dialogue_box.raise()
		elif dialogue_box.has_method("move_to_front"):
			dialogue_box.move_to_front()
	if choice_box:
		_collect_and_free_duplicates(root, choice_box, "ChoiceBox")
		if choice_box.has_method("raise"):
			choice_box.raise()
		elif choice_box.has_method("move_to_front"):
			choice_box.move_to_front()
	if vn_hud:
		_collect_and_free_duplicates(root, vn_hud, "VNHUD")
		if vn_hud.has_method("raise"):
			vn_hud.raise()
		elif vn_hud.has_method("move_to_front"):
			vn_hud.move_to_front()
	
	# Connect settings signals
	if vn_hud and vn_hud.has_signal("settings_requested"):
		vn_hud.settings_requested.connect(_on_settings_changed)

func _on_settings_changed():
	## Handle settings changes
	if vn_hud and dialogue_box:
		# Update text speed
		var text_speed = vn_hud.get_text_speed()
		dialogue_box.set_text_speed(text_speed)
		
		# Update auto advance
		var auto_advance = vn_hud.get_auto_advance()
		dialogue_box.set_auto_advance_enabled(auto_advance)

func _collect_and_free_duplicates(base: Node, keep_node: Node, name_to_find: String) -> void:
	for child in base.get_children():
		if child is Node:
			if child != keep_node and child.name == name_to_find:
				# free duplicates
				child.queue_free()
			else:
				_collect_and_free_duplicates(child, keep_node, name_to_find)

func start_story(story_resource: StoryResource, entry_point: String = "start") -> void:
	## Start a new story from the given entry point
	current_story = story_resource
	current_node_id = entry_point
	story_variables.clear()
	call_stack.clear()
	rollback_buffer.clear()
	current_step = 0
	
	story_started.emit(story_resource.story_data.get("meta", {}).get("title", "Untitled"))
	
	# Execute the entry point
	execute_node(entry_point)

func execute_node(node_id: String) -> void:
	## Execute a story node and handle its type
	var node = current_story.get_node(node_id)
	if node.is_empty():
		push_error("Node not found: " + node_id)
		return
	
	current_node_id = node_id
	node_changed.emit(node_id)
	
	# Save state for rollback
	save_rollback_state()
	
	var node_type = node.get("type", "")
	match node_type:
		"dialogue":
			execute_dialogue_node(node)
		"choice":
			execute_choice_node(node)
		"set_variable":
			execute_variable_node(node)
		"conditional":
			execute_conditional_node(node)
		"jump":
			execute_jump_node(node)
		"call":
			execute_call_node(node)
		"return":
			execute_return_node(node)
		_:
			push_error("Unknown node type: " + node_type)

func execute_dialogue_node(node: Dictionary) -> void:
	## Execute a dialogue node
	var speaker = node.get("speaker", "")
	var text = node.get("text", "")
	var metadata = node.get("metadata", {})
	
	# Process text through localization
	text = localization.translate(text)
	
	# Show dialogue
	show_text(speaker, text, metadata)
	
	# Wait for text to finish or user input
	if dialogue_box:
		await dialogue_box.text_finished
		
		# Wait for user click to continue (unless auto advance is enabled)
		if vn_hud and vn_hud.get_auto_advance():
			# Auto advance is enabled, continue automatically
			pass
		else:
			# Manual advance - wait for user click
			await dialogue_box.text_clicked
	
	# Auto-advance if no next node specified
	var next_node = node.get("next", "")
	if next_node != "":
		execute_node(next_node)

func execute_choice_node(node: Dictionary) -> void:
	## Execute a choice node
	var choices = node.get("options", [])
	var processed_choices = []
	
	for choice in choices:
		var processed_choice = {
			"text": localization.translate(choice.get("text", "")),
			"goto": choice.get("goto", ""),
			"metadata": choice.get("metadata", {})
		}
		processed_choices.append(processed_choice)
	
	var choice_index = await present_choices(processed_choices)
	
	# Execute the chosen option
	if choice_index >= 0 and choice_index < choices.size():
		var chosen_choice = choices[choice_index]
		var next_node = chosen_choice.get("goto", "")
		if next_node != "":
			execute_node(next_node)

func execute_variable_node(node: Dictionary) -> void:
	## Execute a variable setting node
	var var_name = node.get("variable", "")
	var var_value = node.get("value", "")
	
	# Evaluate expression if needed
	if var_value is String and var_value.begins_with("$"):
		var_value = evaluate_expression(var_value)
	
	story_variables[var_name] = var_value
	
	# Continue to next node
	var next_node = node.get("next", "")
	if next_node != "":
		execute_node(next_node)

func execute_conditional_node(node: Dictionary) -> void:
	## Execute a conditional node
	var condition = node.get("condition", "")
	var true_goto = node.get("true_goto", "")
	var false_goto = node.get("false_goto", "")
	
	var result = evaluate_expression(condition)
	var next_node = true_goto if result else false_goto
	
	if next_node != "":
		execute_node(next_node)

func execute_jump_node(node: Dictionary) -> void:
	## Execute a jump node
	var target = node.get("target", "")
	if target != "":
		execute_node(target)

func execute_call_node(node: Dictionary) -> void:
	## Execute a call node (subroutine)
	var target = node.get("target", "")
	if target != "":
		# Save current position to call stack
		call_stack.append(current_node_id)
		execute_node(target)

func execute_return_node(node: Dictionary) -> void:
	## Execute a return node
	if call_stack.size() > 0:
		var return_node = call_stack.pop_back()
		var next_node = node.get("next", "")
		if next_node != "":
			execute_node(next_node)
		else:
			execute_node(return_node)

func show_text(character_id: String, text: String, metadata: Dictionary = {}) -> void:
	## Display text in the dialogue box
	if dialogue_box:
		dialogue_box.show_text(character_id, text, metadata)
	
	text_shown.emit(character_id, text, metadata)

func present_choices(choices: Array) -> int:
	## Present choices to the player and return the selected index
	if choice_box:
		choice_box.present_choices(choices)
	
	choice_presented.emit(choices)
	
	# Wait for choice selection
	var choice_index = await choice_box.choice_selected
	choice_made.emit(choice_index, choices[choice_index].get("metadata", {}))
	
	# Hide choice box
	choice_box.hide_choices()
	
	return choice_index

func save(slot: int = 0) -> bool:
	## Save the current game state to a slot
	var save_data = {
		"version": 1,
		"story_path": current_story.resource_path if current_story else "",
		"current_node": current_node_id,
		"variables": story_variables.duplicate(true),
		"call_stack": call_stack.duplicate(true),
		"step": current_step,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var success = save_system.save_to_slot(slot, save_data)
	if success:
		save_created.emit(slot)
	return success

func load_game(slot: int = 0) -> bool:
	## Load a game state from a slot
	var save_data = save_system.load_from_slot(slot)
	if save_data.is_empty():
		return false
	
	# Load story
	if save_data.has("story_path") and save_data["story_path"] != "":
		current_story = load(save_data["story_path"]) as StoryResource
	
	# Restore state
	current_node_id = save_data.get("current_node", "")
	story_variables = save_data.get("variables", {})
	call_stack = save_data.get("call_stack", [])
	current_step = save_data.get("step", 0)
	
	save_loaded.emit(slot)
	
	# Continue from saved node
	if current_node_id != "":
		execute_node(current_node_id)
	
	return true

func quicksave() -> void:
	## Perform a quicksave
	save(auto_save_slot)

func quickload() -> void:
	## Perform a quickload
	load_game(auto_save_slot)

func rollback(steps: int = 1) -> void:
	## Rollback the specified number of steps
	if rollback_buffer.size() < steps:
		push_warning("Not enough rollback data")
		return
	
	# Restore state from rollback buffer
	var target_step = current_step - steps
	var state_data = rollback_buffer[target_step]
	
	story_variables = state_data.get("variables", {})
	call_stack = state_data.get("call_stack", [])
	current_step = target_step
	
	# Execute from the rolled back node
	var node_id = state_data.get("node_id", "")
	if node_id != "":
		execute_node(node_id)

func save_rollback_state() -> void:
	## Save current state for rollback
	var state_data = {
		"node_id": current_node_id,
		"variables": story_variables.duplicate(true),
		"call_stack": call_stack.duplicate(true),
		"step": current_step
	}
	
	rollback_buffer.append(state_data)
	
	# Limit rollback buffer size
	if rollback_buffer.size() > max_rollback_steps:
		rollback_buffer.pop_front()

func set_language(lang_code: String) -> void:
	## Set the current language for localization
	localization.set_language(lang_code)

func evaluate_expression(expression: String) -> Variant:
	## Evaluate a simple expression with story variables
	# Simple expression evaluator
	# Supports basic operations and variable references
	if expression.begins_with("$"):
		var var_name = expression.substr(1)
		return story_variables.get(var_name, null)
	
	# Handle basic comparisons
	if "==" in expression:
		var parts = expression.split("==")
		if parts.size() == 2:
			var left = evaluate_expression(parts[0].strip_edges())
			var right = evaluate_expression(parts[1].strip_edges())
			return left == right
	
	if "!=" in expression:
		var parts = expression.split("!=")
		if parts.size() == 2:
			var left = evaluate_expression(parts[0].strip_edges())
			var right = evaluate_expression(parts[1].strip_edges())
			return left != right
	
	# Handle numeric comparisons
	if ">=" in expression:
		var parts = expression.split(">=")
		if parts.size() == 2:
			var left = evaluate_expression(parts[0].strip_edges())
			var right = evaluate_expression(parts[1].strip_edges())
			return left >= right
	
	if "<=" in expression:
		var parts = expression.split("<=")
		if parts.size() == 2:
			var left = evaluate_expression(parts[0].strip_edges())
			var right = evaluate_expression(parts[1].strip_edges())
			return left <= right
	
	# Try to parse as number
	if expression.is_valid_float():
		return expression.to_float()
	
	# Try to parse as integer
	if expression.is_valid_int():
		return expression.to_int()
	
	# Return as string
	return expression

func random() -> float:
	## Get a deterministic random value
	random_seed = (random_seed * 1103515245 + 12345) & 0x7FFFFFFF
	return float(random_seed) / 2147483647.0

func randomize_seed() -> void:
	## Set a new random seed
	random_seed = randi()

func get_variable(var_name: String) -> Variant:
	## Get a story variable value
	return story_variables.get(var_name, null)

func set_variable(var_name: String, value: Variant) -> void:
	## Set a story variable value
	story_variables[var_name] = value
