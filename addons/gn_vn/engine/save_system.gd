class_name SaveSystem
extends Node

## Handles save/load operations with JSON format
## Provides portable, human-readable saves with schema versioning

const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".json"

func _ready():
	# Ensure save directory exists
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_to_slot(slot: int, save_data: Dictionary) -> bool:
	"""Save data to a specific slot"""
	var file_path = SAVE_DIR + "save_" + str(slot) + SAVE_EXTENSION
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file: " + file_path)
		return false
	
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	return true

func load_from_slot(slot: int) -> Dictionary:
	"""Load data from a specific slot"""
	var file_path = SAVE_DIR + "save_" + str(slot) + SAVE_EXTENSION
	
	if not FileAccess.file_exists(file_path):
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open save file: " + file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse save file: " + json.get_error_message())
		return {}
	
	return json.data

func get_save_info(slot: int) -> Dictionary:
	"""Get metadata about a save slot"""
	var save_data = load_from_slot(slot)
	if save_data.is_empty():
		return {}
	
	return {
		"slot": slot,
		"timestamp": save_data.get("timestamp", 0),
		"story_title": save_data.get("story_title", "Unknown"),
		"current_node": save_data.get("current_node", ""),
		"exists": true
	}

func delete_slot(slot: int) -> bool:
	"""Delete a save slot"""
	var file_path = SAVE_DIR + "save_" + str(slot) + SAVE_EXTENSION
	
	if not FileAccess.file_exists(file_path):
		return false
	
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.remove(file_path)
		return true
	
	return false

func get_all_saves() -> Array:
	"""Get information about all save slots"""
	var saves = []
	
	for i in range(100):  # Check slots 0-99
		var save_info = get_save_info(i)
		if not save_info.is_empty():
			saves.append(save_info)
	
	return saves

func export_save(slot: int, export_path: String) -> bool:
	"""Export a save to a specific path"""
	var save_data = load_from_slot(slot)
	if save_data.is_empty():
		return false
	
	var file = FileAccess.open(export_path, FileAccess.WRITE)
	if not file:
		return false
	
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	return true

func import_save(import_path: String, slot: int) -> bool:
	"""Import a save from a specific path to a slot"""
	var file = FileAccess.open(import_path, FileAccess.READ)
	if not file:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return false
	
	return save_to_slot(slot, json.data)
