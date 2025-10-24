extends Control

## Demo scene script for GN_VN
## Shows how to use the VN system in a game

@onready var vn_manager: VNManager = get_node("/root/VisualNovelManager")
@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var choice_box: ChoiceBox = $ChoiceBox
@onready var vn_hud: VNHUD = $VNHUD

func _ready():
	# Connect signals
	setup_signals()
	
	# Load and start the demo story
	load_demo_story()

func setup_signals():
	## Setup signal connections
	# VN Manager signals
	vn_manager.story_started.connect(_on_story_started)
	vn_manager.story_ended.connect(_on_story_ended)
	vn_manager.text_shown.connect(_on_text_shown)
	vn_manager.choice_presented.connect(_on_choice_presented)
	vn_manager.choice_made.connect(_on_choice_made)
	
	# UI signals
	dialogue_box.text_clicked.connect(_on_dialogue_clicked)
	choice_box.choice_selected.connect(_on_choice_selected)
	vn_hud.save_requested.connect(_on_save_requested)
	vn_hud.load_requested.connect(_on_load_requested)
	vn_hud.settings_requested.connect(_on_settings_requested)
	vn_hud.quit_requested.connect(_on_quit_requested)

func load_demo_story():
	## Load the demo story
	var story_path = "res://addons/gn_vn/samples/demo.story.json"
	var file = FileAccess.open(story_path, FileAccess.READ)
	if not file:
		push_error("Failed to load demo story")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var story_resource = StoryResource.new()
	if story_resource.load_from_json(json_string):
		vn_manager.start_story(story_resource, "start")
	else:
		push_error("Failed to parse demo story")

func _on_story_started(story_title: String):
	## Handle story start
	print("Story started: ", story_title)

func _on_story_ended():
	## Handle story end
	print("Story ended")

func _on_text_shown(character_id: String, text: String, metadata: Dictionary):
	## Handle text shown
	print("Text shown: ", character_id, " - ", text)

func _on_choice_presented(choices: Array):
	## Handle choice presented
	print("Choices presented: ", choices.size())

func _on_choice_made(choice_index: int, metadata: Dictionary):
	## Handle choice made
	print("Choice made: ", choice_index)

func _on_dialogue_clicked():
	## Handle dialogue click
	# This would advance the story
	pass

func _on_choice_selected(choice_index: int):
	## Handle choice selection
	# The VNManager will handle the choice automatically
	print("Choice selected: ", choice_index)

func _on_save_requested(slot: int):
	## Handle save request
	vn_manager.save(slot)
	print("Game saved to slot ", slot)

func _on_load_requested(slot: int):
	## Handle load request
	vn_manager.load_game(slot)
	print("Game loaded from slot ", slot)

func _on_settings_requested():
	## Handle settings request
	print("Settings requested")

func _on_quit_requested():
	## Handle quit request
	get_tree().quit()

func _input(event: InputEvent):
	## Handle input events
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F5:
				# Quicksave
				vn_manager.quicksave()
			KEY_F9:
				# Quickload
				vn_manager.quickload()
			KEY_R:
				# Rollback
				vn_manager.rollback(1)
			KEY_ESCAPE:
				# Show menu or quit
				_on_quit_requested()
