class_name StoryImporter
extends RefCounted

## Utility class for importing stories from various formats
## Supports CSV, JSON, and other common story formats

static func import_from_csv(file_path: String) -> StoryResource:
	##Import a story from CSV format##
	var story = StoryResource.new()
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if not file:
		push_error("Failed to open CSV file: " + file_path)
		return story
	
	var lines = file.get_as_text().split("\n")
	file.close()
	
	if lines.size() < 2:
		push_error("CSV file is too short")
		return story
	
	# Parse header
	var header = parse_csv_line(lines[0])
	var node_id_index = header.find("id")
	var type_index = header.find("type")
	var speaker_index = header.find("speaker")
	var text_index = header.find("text")
	var next_index = header.find("next")
	
	if node_id_index == -1 or type_index == -1:
		push_error("CSV file missing required columns: id, type")
		return story
	
	# Parse data rows
	for i in range(1, lines.size()):
		if lines[i].strip_edges().is_empty():
			continue
		
		var row = parse_csv_line(lines[i])
		if row.size() <= max(node_id_index, type_index):
			continue
		
		var node = {
			"id": row[node_id_index],
			"type": row[type_index]
		}
		
		if speaker_index != -1 and row.size() > speaker_index:
			node["speaker"] = row[speaker_index]
		
		if text_index != -1 and row.size() > text_index:
			node["text"] = row[text_index]
		
		if next_index != -1 and row.size() > next_index:
			node["next"] = row[next_index]
		
		story.add_node(node)
	
	return story

static func import_from_renpy(file_path: String) -> StoryResource:
	##Import a story from Ren'Py format (basic implementation)##
	var story = StoryResource.new()
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if not file:
		push_error("Failed to open Ren'Py file: " + file_path)
		return story
	
	var content = file.get_as_text()
	file.close()
	
	# Basic Ren'Py parser (simplified)
	var lines = content.split("\n")
	var current_node_id = "start"
	var node_counter = 0
	
	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		
		# Handle character dialogue
		if " " in line and not line.begins_with("    "):
			var parts = line.split(" ", false, 1)
			if parts.size() == 2:
				var speaker = parts[0]
				var text = parts[1]
				
				var node = {
					"id": current_node_id,
					"type": "dialogue",
					"speaker": speaker,
					"text": text
				}
				
				story.add_node(node)
				node_counter += 1
				current_node_id = "node_" + str(node_counter)
		
		# Handle menu choices
		elif line.begins_with("menu:"):
			var node = {
				"id": current_node_id,
				"type": "choice",
				"options": []
			}
			story.add_node(node)
			node_counter += 1
			current_node_id = "node_" + str(node_counter)
	
	return story

static func export_to_csv(story: StoryResource, file_path: String) -> bool:
	##Export a story to CSV format##
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return false
	
	# Write header
	file.store_line("id,type,speaker,text,next")
	
	# Write data
	var nodes = story.get_all_nodes()
	for node in nodes:
		var line = str(node.get("id", "")) + ","
		line += str(node.get("type", "")) + ","
		line += str(node.get("speaker", "")) + ","
		line += str(node.get("text", "")) + ","
		line += str(node.get("next", ""))
		file.store_line(line)
	
	file.close()
	return true

static func parse_csv_line(line: String) -> Array:
	##Parse a CSV line handling quoted fields##
	var result = []
	var current_field = ""
	var in_quotes = false
	var i = 0
	
	while i < line.length():
		var char = line[i]
		
		if char == "\"":
			if in_quotes and i + 1 < line.length() and line[i + 1] == "\"":
				# Escaped quote
				current_field += "\""
				i += 2
				continue
			else:
				# Toggle quote state
				in_quotes = !in_quotes
		elif char == "," and not in_quotes:
			# Field separator
			result.append(current_field)
			current_field = ""
		else:
			current_field += char
		
		i += 1
	
	# Add last field
	result.append(current_field)
	return result

static func validate_story(story: StoryResource) -> Array:
	##Validate a story and return any errors##
	var errors = []
	var nodes = story.get_all_nodes()
	var node_ids = []
	
	# Check for duplicate node IDs
	for node in nodes:
		var node_id = node.get("id", "")
		if node_id.is_empty():
			errors.append("Node missing ID")
		elif node_id in node_ids:
			errors.append("Duplicate node ID: " + node_id)
		else:
			node_ids.append(node_id)
	
	# Check for missing references
	for node in nodes:
		var next_node = node.get("next", "")
		if next_node != "" and not next_node in node_ids:
			errors.append("Node " + node.get("id", "") + " references non-existent node: " + next_node)
		
		# Check choice options
		if node.get("type") == "choice":
			var options = node.get("options", [])
			for option in options:
				var goto = option.get("goto", "")
				if goto != "" and not goto in node_ids:
					errors.append("Choice in node " + node.get("id", "") + " references non-existent node: " + goto)
	
	return errors
