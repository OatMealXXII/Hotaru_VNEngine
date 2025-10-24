class_name StoryResource
extends Resource

## A resource that holds story data in JSON format
## This allows stories to be saved as .tres files and loaded in the editor

@export var story_data: Dictionary = {}

func _init():
	story_data = {
		"meta": {
			"title": "Untitled Story",
			"version": "1.0.0",
			"author": "Unknown"
		},
		"nodes": []
	}

func load_from_json(json_string: String) -> bool:
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse JSON: " + json.get_error_message())
		return false
	
	story_data = json.data
	return true

func to_json_string() -> String:
	var json = JSON.new()
	return json.stringify(story_data, "\t")

func add_node(node_data: Dictionary) -> void:
	if not story_data.has("nodes"):
		story_data["nodes"] = []
	story_data["nodes"].append(node_data)

func get_node(node_id: String) -> Dictionary:
	if not story_data.has("nodes"):
		return {}
	
	for node in story_data["nodes"]:
		if node.get("id") == node_id:
			return node
	
	return {}

func get_all_nodes() -> Array:
	return story_data.get("nodes", [])
