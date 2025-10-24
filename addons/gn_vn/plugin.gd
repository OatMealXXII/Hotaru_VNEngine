@tool
extends EditorPlugin

const StoryEditorControl = preload("res://addons/gn_vn/editor/story_editor_plugin.gd")

var story_editor_control: StoryEditorControl

func _enter_tree():
	# Add the story editor dock
	story_editor_control = StoryEditorControl.new()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, story_editor_control)
	
	# Register custom resource types (commented out for now)
	# add_custom_type("StoryResource", "Resource", preload("res://addons/gn_vn/engine/story_resource.gd"), preload("res://addons/gn_vn/icons/story_icon.png"))

func _exit_tree():
	# Remove the dock
	if story_editor_control:
		remove_control_from_docks(story_editor_control)
		story_editor_control = null
	
	# Remove custom types (commented out for now)
	# remove_custom_type("StoryResource")
