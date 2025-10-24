extends Control

## Comprehensive test scene for GN_VN
## Tests all major functionality of the Visual Novel Engine

@onready var vn_manager: VNManager = $VNManager
@onready var test_results: RichTextLabel = $TestResults

var test_results_text: String = ""
var test_story: StoryResource

func _ready():
	# Run comprehensive tests
	run_comprehensive_tests()

func run_comprehensive_tests():
	##Run comprehensive tests for all GN_VN functionality##
	test_results_text = "[b]GN_VN Comprehensive Test Suite[/b]\n\n"
	
	# Test 1: Story Resource Creation
	test_story_resource_creation()
	
	# Test 2: Basic Dialogue System
	test_dialogue_system()
	
	# Test 3: Choice System
	test_choice_system()
	
	# Test 4: Variable System
	test_variable_system()
	
	# Test 5: Save/Load System
	test_save_load_system()
	
	# Test 6: Localization System
	test_localization_system()
	
	# Test 7: Audio System
	test_audio_system()
	
	# Test 8: Transition System
	test_transition_system()
	
	# Display results
	test_results.text = test_results_text

func test_story_resource_creation():
	##Test StoryResource creation and manipulation##
	add_test_result("Test 1: Story Resource Creation")
	
	# Create story resource
	var story = StoryResource.new()
	
	# Test basic properties
	if story.story_data.has("meta") and story.story_data.has("nodes"):
		add_test_result("✓ Story resource created with correct structure")
	else:
		add_test_result("✗ Story resource structure incorrect")
	
	# Test adding nodes
	var test_node = {
		"id": "test_node",
		"type": "dialogue",
		"speaker": "Test",
		"text": "Hello World"
	}
	story.add_node(test_node)
	
	var retrieved_node = story.get_node("test_node")
	if not retrieved_node.is_empty() and retrieved_node.get("speaker") == "Test":
		add_test_result("✓ Node addition and retrieval working")
	else:
		add_test_result("✗ Node addition or retrieval failed")
	
	# Test JSON serialization
	var json_string = story.to_json_string()
	if json_string.length() > 0 and json_string.contains("test_node"):
		add_test_result("✓ JSON serialization working")
	else:
		add_test_result("✗ JSON serialization failed")

func test_dialogue_system():
	##Test dialogue system functionality##
	add_test_result("\nTest 2: Dialogue System")
	
	# Create dialogue test story
	var story = StoryResource.new()
	story.story_data = {
		"meta": {"title": "Dialogue Test"},
		"nodes": [
			{
				"id": "start",
				"type": "dialogue",
				"speaker": "Alice",
				"text": "Hello! This is a **bold** and *italic* test.",
				"next": "end"
			},
			{
				"id": "end",
				"type": "dialogue",
				"speaker": "Narrator",
				"text": "Dialogue test completed."
			}
		]
	}
	
	# Start story
	vn_manager.start_story(story, "start")
	
	# Check if dialogue was processed
	if vn_manager.current_node_id == "start":
		add_test_result("✓ Story started correctly")
	else:
		add_test_result("✗ Story start failed")
	
	# Test text formatting
	var processed_text = vn_manager.dialogue_box.text_label.text if vn_manager.dialogue_box else ""
	if processed_text.contains("[b]bold[/b]") and processed_text.contains("[i]italic[/i]"):
		add_test_result("✓ Text formatting applied correctly")
	else:
		add_test_result("✗ Text formatting not applied")

func test_choice_system():
	##Test choice system functionality##
	add_test_result("\nTest 3: Choice System")
	
	# Create choice test story
	var story = StoryResource.new()
	story.story_data = {
		"meta": {"title": "Choice Test"},
		"nodes": [
			{
				"id": "start",
				"type": "choice",
				"options": [
					{"text": "Option A", "goto": "option_a"},
					{"text": "Option B", "goto": "option_b"}
				]
			},
			{
				"id": "option_a",
				"type": "dialogue",
				"speaker": "Narrator",
				"text": "You chose Option A."
			},
			{
				"id": "option_b",
				"type": "dialogue",
				"speaker": "Narrator",
				"text": "You chose Option B."
			}
		]
	}
	
	# Start story
	vn_manager.start_story(story, "start")
	
	# Check if choices were presented
	if vn_manager.choice_box.get_choice_count() == 2:
		add_test_result("✓ Choices presented correctly")
	else:
		add_test_result("✗ Choices not presented correctly")

func test_variable_system():
	##Test variable system functionality##
	add_test_result("\nTest 4: Variable System")
	
	# Test variable setting and getting
	vn_manager.set_variable("test_string", "Hello")
	vn_manager.set_variable("test_number", 42)
	vn_manager.set_variable("test_boolean", true)
	
	# Test variable retrieval
	if vn_manager.get_variable("test_string") == "Hello":
		add_test_result("✓ String variable working")
	else:
		add_test_result("✗ String variable failed")
	
	if vn_manager.get_variable("test_number") == 42:
		add_test_result("✓ Number variable working")
	else:
		add_test_result("✗ Number variable failed")
	
	if vn_manager.get_variable("test_boolean") == true:
		add_test_result("✓ Boolean variable working")
	else:
		add_test_result("✗ Boolean variable failed")
	
	# Test expression evaluation
	var result = vn_manager.evaluate_expression("$test_number >= 40")
	if result == true:
		add_test_result("✓ Expression evaluation working")
	else:
		add_test_result("✗ Expression evaluation failed")

func test_save_load_system():
	##Test save/load system functionality##
	add_test_result("\nTest 5: Save/Load System")
	
	# Set some test data
	vn_manager.set_variable("save_test", "test_value")
	vn_manager.current_node_id = "test_node"
	
	# Test save
	var save_success = vn_manager.save(99)
	if save_success:
		add_test_result("✓ Save operation successful")
	else:
		add_test_result("✗ Save operation failed")
		return
	
	# Modify data
	vn_manager.set_variable("save_test", "modified_value")
	vn_manager.current_node_id = "modified_node"
	
	# Test load
	var load_success = vn_manager.load_game(99)
	if load_success:
		add_test_result("✓ Load operation successful")
		
		# Check if data was restored
		if vn_manager.get_variable("save_test") == "test_value":
			add_test_result("✓ Variable data restored correctly")
		else:
			add_test_result("✗ Variable data not restored")
		
		if vn_manager.current_node_id == "test_node":
			add_test_result("✓ Node ID restored correctly")
		else:
			add_test_result("✗ Node ID not restored")
	else:
		add_test_result("✗ Load operation failed")

func test_localization_system():
	##Test localization system functionality##
	add_test_result("\nTest 6: Localization System")
	
	# Test language setting
	vn_manager.set_language("en")
	if vn_manager.localization.get_current_language() == "en":
		add_test_result("✓ Language setting working")
	else:
		add_test_result("✗ Language setting failed")
	
	# Test translation
	var translated = vn_manager.localization.translate("#continue")
	if translated == "Continue":
		add_test_result("✓ Translation working")
	else:
		add_test_result("✗ Translation failed")

func test_audio_system():
	##Test audio system functionality##
	add_test_result("\nTest 7: Audio System")
	
	# Test volume setting
	vn_manager.audio_manager.set_voice_volume(0.5)
	vn_manager.audio_manager.set_music_volume(0.7)
	vn_manager.audio_manager.set_sfx_volume(0.8)
	
	if vn_manager.audio_manager.voice_volume == 0.5:
		add_test_result("✓ Voice volume setting working")
	else:
		add_test_result("✗ Voice volume setting failed")
	
	if vn_manager.audio_manager.music_volume == 0.7:
		add_test_result("✓ Music volume setting working")
	else:
		add_test_result("✗ Music volume setting failed")
	
	if vn_manager.audio_manager.sfx_volume == 0.8:
		add_test_result("✓ SFX volume setting working")
	else:
		add_test_result("✗ SFX volume setting failed")

func test_transition_system():
	##Test transition system functionality##
	add_test_result("\nTest 8: Transition System")
	
	# Test transition creation
	if vn_manager.transition:
		add_test_result("✓ Transition system initialized")
	else:
		add_test_result("✗ Transition system not initialized")
	
	# Test transition duration setting
	vn_manager.transition.set_transition_duration(2.0)
	if vn_manager.transition.transition_duration == 2.0:
		add_test_result("✓ Transition duration setting working")
	else:
		add_test_result("✗ Transition duration setting failed")

func add_test_result(text: String):
	##Add a test result to the output##
	test_results_text += text + "\n"
	print(text)
