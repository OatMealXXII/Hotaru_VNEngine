@tool
extends Control

## Story Editor Plugin for GN_VN
## Provides a dock panel for editing stories in the Godot editor

signal story_loaded(story_resource: StoryResource)
signal story_saved(story_resource: StoryResource)

# UI elements
var main_vbox: VBoxContainer
var file_controls: HBoxContainer
var story_tree: Tree
var node_editor: VBoxContainer
var preview_button: Button

# Current story
var current_story: StoryResource
var selected_node_id: String = ""

func _init():
	name = "Hotaru Visual Novel Engine Story Editor"
	custom_minimum_size = Vector2(400, 600)

func _ready():
	setup_ui()
	setup_signals()

func setup_ui():
	##Setup the editor UI##
	# Main container
	main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_vbox)
	
	# File controls
	setup_file_controls()
	
	# Story tree
	setup_story_tree()
	
	# Node editor
	setup_node_editor()
	
	# Preview button
	setup_preview_button()

func setup_file_controls():
	##Setup file operation controls##
	file_controls = HBoxContainer.new()
	main_vbox.add_child(file_controls)
	
	var new_button = Button.new()
	new_button.text = "New"
	new_button.pressed.connect(_on_new_story)
	file_controls.add_child(new_button)
	
	var load_button = Button.new()
	load_button.text = "Load"
	load_button.pressed.connect(_on_load_story)
	file_controls.add_child(load_button)
	
	var save_button = Button.new()
	save_button.text = "Save"
	save_button.pressed.connect(_on_save_story)
	file_controls.add_child(save_button)
	
	var import_button = Button.new()
	import_button.text = "Import"
	import_button.pressed.connect(_on_import_story)
	file_controls.add_child(import_button)
	
	var export_button = Button.new()
	export_button.text = "Export"
	export_button.pressed.connect(_on_export_story)
	file_controls.add_child(export_button)

func setup_story_tree():
	##Setup the story node tree##
	var tree_label = Label.new()
	tree_label.text = "Story Nodes"
	main_vbox.add_child(tree_label)
	
	story_tree = Tree.new()
	story_tree.custom_minimum_size = Vector2(0, 200)
	story_tree.item_selected.connect(_on_node_selected)
	main_vbox.add_child(story_tree)

func setup_node_editor():
	##Setup the node editor panel##
	var editor_label = Label.new()
	editor_label.text = "Node Editor"
	main_vbox.add_child(editor_label)
	
	node_editor = VBoxContainer.new()
	node_editor.custom_minimum_size = Vector2(0, 150)
	main_vbox.add_child(node_editor)

func setup_preview_button():
	##Setup preview button##
	preview_button = Button.new()
	preview_button.text = "Preview Story"
	preview_button.pressed.connect(_on_preview_story)
	main_vbox.add_child(preview_button)

func setup_signals():
	##Setup signal connections##
	# Signals are connected in setup functions
	pass
func _on_new_story():
	##Create a new story##
	current_story = StoryResource.new()
	refresh_story_tree()
	story_loaded.emit(current_story)

func _on_load_story():
	##Load a story from file##
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.tres", "Godot Resource")
	file_dialog.add_filter("*.json", "JSON Story")
	file_dialog.file_selected.connect(_on_story_file_selected)
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_save_story():
	##Save the current story##
	if not current_story:
		push_warning("No story to save")
		return
	
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.add_filter("*.tres", "Godot Resource")
	file_dialog.add_filter("*.json", "JSON Story")
	file_dialog.file_selected.connect(_on_story_save_selected)
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_import_story():
	##Import story from external format##
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.csv", "CSV Translation")
	file_dialog.file_selected.connect(_on_import_file_selected)
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_export_story():
	##Export story to external format##
	if not current_story:
		push_warning("No story to export")
		return
	
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.add_filter("*.csv", "CSV Translation")
	file_dialog.file_selected.connect(_on_export_file_selected)
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_preview_story():
	##Preview the current story##
	if not current_story:
		push_warning("No story to preview")
		return
	
	# Create a preview scene
	var preview_scene = preload("res://addons/gn_vn/samples/demo_scene.tscn")
	var preview_instance = preview_scene.instantiate()
	
	# Get the main scene and add preview
	var main_scene = EditorInterface.get_edited_scene_root()
	if main_scene:
		main_scene.add_child(preview_instance)
		# Start the story
		if preview_instance.has_method("start_demo"):
			preview_instance.start_demo()
	else:
		push_warning("No main scene to preview in")

func _on_story_file_selected(path: String):
	##Handle story file selection##
	if path.ends_with(".tres"):
		current_story = load(path)
	elif path.ends_with(".json"):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			current_story = StoryResource.new()
			current_story.load_from_json(json_string)
	
	if current_story:
		refresh_story_tree()
		story_loaded.emit(current_story)

func _on_story_save_selected(path: String):
	##Handle story save selection##
	if not current_story:
		return
	
	if path.ends_with(".tres"):
		ResourceSaver.save(current_story, path)
	elif path.ends_with(".json"):
		var file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_string(current_story.to_json_string())
			file.close()
	
	story_saved.emit(current_story)

func _on_import_file_selected(path: String):
	##Handle import file selection##
	if path.ends_with(".csv"):
		# Import CSV translation file
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var csv_content = file.get_as_text()
			file.close()
			# Parse CSV and update story
			parse_csv_translation(csv_content)
	else:
		push_warning("Unsupported import format")

func _on_export_file_selected(path: String):
	##Handle export file selection##
	if not current_story:
		push_warning("No story to export")
		return
	
	if path.ends_with(".csv"):
		# Export as CSV translation file
		var csv_content = generate_csv_translation()
		var file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_string(csv_content)
			file.close()
			print("Story exported to: ", path)
	else:
		push_warning("Unsupported export format")

func parse_csv_translation(csv_content: String):
	##Parse CSV translation content##
	# Basic CSV parsing - would need more robust implementation
	var lines = csv_content.split("\n")
	for line in lines:
		if line.strip() != "":
			var parts = line.split(",")
			if parts.size() >= 2:
				var key = parts[0].strip()
				var value = parts[1].strip()
				# Update story with translation
				print("Translation: ", key, " -> ", value)

func generate_csv_translation() -> String:
	##Generate CSV translation content##
	var csv_lines = []
	csv_lines.append("key,translation")
	
	if current_story:
		var nodes = current_story.get_all_nodes()
		for node in nodes:
			if node.get("type") == "dialogue":
				var text = node.get("text", "")
				if text != "":
					csv_lines.append('"' + text + '","' + text + '"')
	
	return "\n".join(csv_lines)

func refresh_story_tree():
	##Refresh the story tree display##
	story_tree.clear()
	
	if not current_story:
		return
	
	var root = story_tree.create_item()
	root.set_text(0, "Story: " + current_story.story_data.get("meta", {}).get("title", "Untitled"))
	
	var nodes = current_story.get_all_nodes()
	for node in nodes:
		var item = story_tree.create_item(root)
		var node_type = node.get("type", "unknown")
		var node_id = node.get("id", "unnamed")
		item.set_text(0, node_type + ": " + node_id)
		item.set_metadata(0, node_id)

func _on_node_selected():
	##Handle node selection in tree##
	var selected = story_tree.get_selected()
	if selected and selected.get_metadata(0) != null:
		selected_node_id = selected.get_metadata(0)
		refresh_node_editor()

func refresh_node_editor():
	##Refresh the node editor##
	# Clear existing editor
	for child in node_editor.get_children():
		child.queue_free()
	
	if not current_story or selected_node_id == "":
		return
	
	var node = current_story.get_node(selected_node_id)
	if node.is_empty():
		return
	
	# Create editor based on node type
	var node_type = node.get("type", "")
	match node_type:
		"dialogue":
			create_dialogue_editor(node)
		"choice":
			create_choice_editor(node)
		"set_variable":
			create_variable_editor(node)
		_:
			create_generic_editor(node)

func create_dialogue_editor(node: Dictionary):
	##Create editor for dialogue nodes##
	var speaker_label = Label.new()
	speaker_label.text = "Speaker:"
	node_editor.add_child(speaker_label)
	
	var speaker_edit = LineEdit.new()
	speaker_edit.text = node.get("speaker", "")
	speaker_edit.text_changed.connect(_on_speaker_changed)
	node_editor.add_child(speaker_edit)
	
	var text_label = Label.new()
	text_label.text = "Text:"
	node_editor.add_child(text_label)
	
	var text_edit = TextEdit.new()
	text_edit.text = node.get("text", "")
	text_edit.custom_minimum_size = Vector2(0, 100)
	text_edit.text_changed.connect(_on_text_changed)
	node_editor.add_child(text_edit)

func create_choice_editor(node: Dictionary):
	##Create editor for choice nodes##
	var choices_label = Label.new()
	choices_label.text = "Choices:"
	node_editor.add_child(choices_label)
	
	# This would be expanded to show individual choice editors
	var choices_text = TextEdit.new()
	choices_text.text = JSON.stringify(node.get("options", []), "\t")
	choices_text.custom_minimum_size = Vector2(0, 100)
	node_editor.add_child(choices_text)

func create_variable_editor(node: Dictionary):
	##Create editor for variable nodes##
	var var_label = Label.new()
	var_label.text = "Variable:"
	node_editor.add_child(var_label)
	
	var var_edit = LineEdit.new()
	var_edit.text = node.get("variable", "")
	node_editor.add_child(var_edit)
	
	var value_label = Label.new()
	value_label.text = "Value:"
	node_editor.add_child(value_label)
	
	var value_edit = LineEdit.new()
	value_edit.text = str(node.get("value", ""))
	node_editor.add_child(value_edit)

func create_generic_editor(node: Dictionary):
	##Create generic editor for unknown node types##
	var json_label = Label.new()
	json_label.text = "Node Data:"
	node_editor.add_child(json_label)
	
	var json_edit = TextEdit.new()
	json_edit.text = JSON.stringify(node, "\t")
	json_edit.custom_minimum_size = Vector2(0, 100)
	node_editor.add_child(json_edit)

func _on_speaker_changed(text: String):
	##Handle speaker text change##
	if current_story and selected_node_id != "":
		var node = current_story.get_node(selected_node_id)
		node["speaker"] = text

func _on_text_changed():
	##Handle text change##
	if current_story and selected_node_id != "":
		var node = current_story.get_node(selected_node_id)
		# Find the text edit in the node editor
		var text_edit = null
		for child in node_editor.get_children():
			if child is TextEdit:
				text_edit = child
				break
		if text_edit:
			node["text"] = text_edit.text


func _on_story_loaded(story_resource: StoryResource) -> void:
	pass # Replace with function body.
