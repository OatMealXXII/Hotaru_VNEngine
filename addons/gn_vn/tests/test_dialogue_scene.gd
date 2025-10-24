extends Control

## Test scene for dialogue and choice functionality
## Verifies that dialogue system works correctly

@onready var vn_manager: VNManager = $VNManager
@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var choice_box: ChoiceBox = $ChoiceBox
@onready var test_results: RichTextLabel = $TestResults

var test_results_text: String = ""
var test_story: StoryResource

func _ready():
	# Run tests
	run_dialogue_tests()

func run_dialogue_tests():
	##Run comprehensive dialogue tests##
	test_results_text = "[b]GN_VN Dialogue System Tests[/b]\n\n"
	
	# Test 1: Basic dialogue
	test_basic_dialogue()
	
	# Test 2: Choice system
	test_choice_system()
	
	# Test 3: Text formatting
	test_text_formatting()
	
	# Test 4: Variable evaluation
	test_variable_evaluation()
	
	# Display results
	test_results.text = test_results_text

func test_basic_dialogue():
	##Test basic dialogue functionality##
	add_test_result("Test 1: Basic Dialogue")
	
	# Create test story
	test_story = StoryResource.new()
	test_story.story_data = {
		"meta": {"title": "Dialogue Test"},
		"nodes": [
			{
				"id": "start",
				"type": "dialogue",
				"speaker": "Test Character",
				"text": "This is a test dialogue.",
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
	vn_manager.start_story(test_story, "start")
	
	# Check if dialogue was shown
	if dialogue_box.name_label.text == "Test Character":
		add_test_result("✓ Character name displayed correctly")
	else:
		add_test_result("✗ Character name not displayed correctly")
	
	if dialogue_box.text_label.text.contains("This is a test dialogue"):
		add_test_result("✓ Dialogue text displayed correctly")
	else:
		add_test_result("✗ Dialogue text not displayed correctly")

func test_choice_system():
	##Test choice system functionality##
	add_test_result("\nTest 2: Choice System")
	
	# Create choice test story
	var choice_story = StoryResource.new()
	choice_story.story_data = {
		"meta": {"title": "Choice Test"},
		"nodes": [
			{
				"id": "start",
				"type": "choice",
				"options": [
					{"text": "Option 1", "goto": "option1"},
					{"text": "Option 2", "goto": "option2"},
					{"text": "Option 3", "goto": "option3"}
				]
			},
			{
				"id": "option1",
				"type": "dialogue",
				"speaker": "Narrator",
				"text": "You chose option 1."
			},
			{
				"id": "option2",
				"type": "dialogue",
				"speaker": "Narrator",
				"text": "You chose option 2."
			},
			{
				"id": "option3",
				"type": "dialogue",
				"speaker": "Narrator",
				"text": "You chose option 3."
			}
		]
	}
	
	# Start choice story
	vn_manager.start_story(choice_story, "start")
	
	# Check if choices were presented
	if choice_box.get_choice_count() == 3:
		add_test_result("✓ Three choices presented correctly")
	else:
		add_test_result("✗ Choices not presented correctly")
	
	# Check choice texts
	var expected_texts = ["Option 1", "Option 2", "Option 3"]
	for i in range(3):
		if choice_box.get_choice_text(i) == expected_texts[i]:
			add_test_result("✓ Choice " + str(i + 1) + " text correct")
		else:
			add_test_result("✗ Choice " + str(i + 1) + " text incorrect")

func test_text_formatting():
	##Test text formatting functionality##
	add_test_result("\nTest 3: Text Formatting")
	
	# Create formatting test story
	var format_story = StoryResource.new()
	format_story.story_data = {
		"meta": {"title": "Formatting Test"},
		"nodes": [
			{
				"id": "start",
				"type": "dialogue",
				"speaker": "Format Test",
				"text": "This has **bold** and *italic* text."
			}
		]
	}
	
	# Start formatting story
	vn_manager.start_story(format_story, "start")
	
	# Check if formatting was applied
	var text = dialogue_box.text_label.text
	if text.contains("[b]bold[/b]"):
		add_test_result("✓ Bold formatting applied correctly")
	else:
		add_test_result("✗ Bold formatting not applied")
	
	if text.contains("[i]italic[/i]"):
		add_test_result("✓ Italic formatting applied correctly")
	else:
		add_test_result("✗ Italic formatting not applied")

func test_variable_evaluation():
	##Test variable evaluation in expressions##
	add_test_result("\nTest 4: Variable Evaluation")
	
	# Set test variables
	vn_manager.set_variable("test_var", "Hello")
	vn_manager.set_variable("number_var", 42)
	vn_manager.set_variable("bool_var", true)
	
	# Test variable evaluation
	var tests = [
		["$test_var", "Hello", "String variable"],
		["$number_var", 42, "Number variable"],
		["$bool_var", true, "Boolean variable"],
		["$test_var == Hello", true, "String comparison"],
		["$number_var >= 40", true, "Number comparison"],
		["$bool_var == true", true, "Boolean comparison"]
	]
	
	for test in tests:
		var expression = test[0]
		var expected = test[1]
		var description = test[2]
		
		var result = vn_manager.evaluate_expression(expression)
		if result == expected:
			add_test_result("✓ " + description + " evaluated correctly")
		else:
			add_test_result("✗ " + description + " evaluation failed")

func add_test_result(text: String):
	##Add a test result to the output##
	test_results_text += text + "\n"
	print(text)
