extends Control

## Test scene for save/load functionality
## Verifies that saves are deterministic and portable

@onready var vn_manager: VNManager = $VNManager
@onready var test_results: RichTextLabel = $TestResults

var test_results_text: String = ""

func _ready():
	# Run tests
	run_save_tests()

func run_save_tests():
	"""Run comprehensive save/load tests"""
	test_results_text = "[b]GN_VN Save System Tests[/b]\n\n"
	
	# Test 1: Basic save/load
	test_basic_save_load()
	
	# Test 2: Variable persistence
	test_variable_persistence()
	
	# Test 3: Rollback functionality
	test_rollback_functionality()
	
	# Test 4: JSON format validation
	test_json_format()
	
	# Display results
	test_results.text = test_results_text

func test_basic_save_load():
	"""Test basic save and load functionality"""
	add_test_result("Test 1: Basic Save/Load")
	
	# Create a simple story
	var story = StoryResource.new()
	story.story_data = {
		"meta": {"title": "Test Story"},
		"nodes": [
			{"id": "start", "type": "dialogue", "speaker": "Test", "text": "Hello World"}
		]
	}
	
	# Start story
	vn_manager.start_story(story, "start")
	
	# Set some variables
	vn_manager.set_variable("test_var", "test_value")
	vn_manager.set_variable("number_var", 42)
	
	# Save
	var save_success = vn_manager.save(0)
	if save_success:
		add_test_result("✓ Save successful")
	else:
		add_test_result("✗ Save failed")
		return
	
	# Modify variables
	vn_manager.set_variable("test_var", "modified_value")
	vn_manager.set_variable("number_var", 100)
	
	# Load
	var load_success = vn_manager.load(0)
	if load_success:
		add_test_result("✓ Load successful")
		
		# Check if variables were restored
		if vn_manager.get_variable("test_var") == "test_value":
			add_test_result("✓ Variable 'test_var' restored correctly")
		else:
			add_test_result("✗ Variable 'test_var' not restored correctly")
		
		if vn_manager.get_variable("number_var") == 42:
			add_test_result("✓ Variable 'number_var' restored correctly")
		else:
			add_test_result("✗ Variable 'number_var' not restored correctly")
	else:
		add_test_result("✗ Load failed")

func test_variable_persistence():
	"""Test that variables persist correctly"""
	add_test_result("\nTest 2: Variable Persistence")
	
	# Set various types of variables
	vn_manager.set_variable("string_var", "Hello")
	vn_manager.set_variable("int_var", 123)
	vn_manager.set_variable("float_var", 45.67)
	vn_manager.set_variable("bool_var", true)
	vn_manager.set_variable("array_var", [1, 2, 3])
	vn_manager.set_variable("dict_var", {"key": "value"})
	
	# Save
	vn_manager.save(1)
	
	# Clear variables
	vn_manager.story_variables.clear()
	
	# Load
	vn_manager.load(1)
	
	# Check each variable type
	var tests = [
		["string_var", "Hello", "String variable"],
		["int_var", 123, "Integer variable"],
		["float_var", 45.67, "Float variable"],
		["bool_var", true, "Boolean variable"],
		["array_var", [1, 2, 3], "Array variable"],
		["dict_var", {"key": "value"}, "Dictionary variable"]
	]
	
	for test in tests:
		var var_name = test[0]
		var expected_value = test[1]
		var description = test[2]
		
		var actual_value = vn_manager.get_variable(var_name)
		if actual_value == expected_value:
			add_test_result("✓ " + description + " persisted correctly")
		else:
			add_test_result("✗ " + description + " not persisted correctly")

func test_rollback_functionality():
	"""Test rollback functionality"""
	add_test_result("\nTest 3: Rollback Functionality")
	
	# Set initial variable
	vn_manager.set_variable("rollback_test", 0)
	
	# Simulate some story progression
	for i in range(5):
		vn_manager.set_variable("rollback_test", i + 1)
		vn_manager.current_step += 1
		vn_manager.save_rollback_state()
	
	# Check current value
	if vn_manager.get_variable("rollback_test") == 5:
		add_test_result("✓ Initial state set correctly")
	else:
		add_test_result("✗ Initial state not set correctly")
		return
	
	# Rollback 2 steps
	vn_manager.rollback(2)
	
	# Check if value was rolled back
	if vn_manager.get_variable("rollback_test") == 3:
		add_test_result("✓ Rollback worked correctly")
	else:
		add_test_result("✗ Rollback failed")

func test_json_format():
	"""Test JSON save format"""
	add_test_result("\nTest 4: JSON Format Validation")
	
	# Save a game
	vn_manager.set_variable("json_test", "test_value")
	vn_manager.save(2)
	
	# Read the save file directly
	var save_path = "user://saves/save_2.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		# Parse JSON
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			add_test_result("✓ JSON format is valid")
			
			var save_data = json.data
			if save_data.has("version") and save_data.has("variables"):
				add_test_result("✓ Save data structure is correct")
			else:
				add_test_result("✗ Save data structure is incorrect")
		else:
			add_test_result("✗ JSON format is invalid")
	else:
		add_test_result("✗ Save file not found")

func add_test_result(text: String):
	"""Add a test result to the output"""
	test_results_text += text + "\n"
	print(text)
