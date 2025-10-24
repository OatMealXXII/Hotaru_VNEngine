@tool
extends EditorPlugin

const StoryEditorPlugin = preload("res://addons/gn_vn/editor/story_editor_plugin.gd")

var story_editor_plugin: StoryEditorPlugin

func _enter_tree():
	# Add the story editor dock
	story_editor_plugin = StoryEditorPlugin.new()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, story_editor_plugin)
	
	# Register custom resource types
	add_custom_type("StoryResource", "Resource", preload("res://addons/gn_vn/engine/story_resource.gd"), preload("res://addons/gn_vn/icons/story_icon.png"))

func _exit_tree():
	# Remove the dock
	if story_editor_plugin:
		remove_control_from_docks(story_editor_plugin)
		story_editor_plugin = null
	
	# Remove custom types
	remove_custom_type("StoryResource")
