# GN_VN - Visual Novel Engine for Godot 4.x

A Visual Novel Engine plugin for Godot 4.x, written entirely in GDScript. GN_VN provides core visual novel functionality with seamless Godot integration.

## 🚀 Current Features

### Core Systems (Implemented)
- **Dialogue System**: Rich text formatting, character names, typing animation
- **Choice System**: Interactive choice selection with branching
- **Save/Load System**: JSON-based save system with multiple slots
- **Rollback System**: Frame-accurate rollback with state management
- **Settings Panel**: Text speed, auto-advance, and volume controls
- **Localization**: Basic translation system with JSON support
- **Audio System**: Voice, music, and sound effect management
- **Story Execution**: Node-based story execution with variables

### Story Node Types (Implemented)
- **Dialogue Nodes**: Character dialogue with text formatting
- **Choice Nodes**: Player choice selection
- **Variable Nodes**: Set story variables
- **Conditional Nodes**: Branch based on variable conditions
- **Jump Nodes**: Navigate to other story nodes
- **Call/Return Nodes**: Subroutine-like story sections

### Text Formatting (Implemented)
- **Bold text**: `**bold**` → `[b]bold[/b]`
- **Italic text**: `*italic*` → `[i]italic[/i]`
- **Colored text**: `{color=red}text{/color}` → `[color=red]text[/color]`
- **Ruby/Furigana**: `[ruby=漢字]kanji[/ruby]` → Small text above base text

### Editor Integration (Basic)
- **Story Editor Dock**: Basic story editing interface
- **Node Tree**: View story structure
- **Node Editor**: Edit individual story nodes
- **Import/Export**: JSON story format support

## 📦 Installation

1. Copy the `addons/gn_vn/` folder to your Godot project
2. Enable the plugin in **Project > Project Settings > Plugins**
3. The "GN VN Story Editor" dock will appear in the editor

## 🎮 Quick Start

### Basic Usage

```gdscript
# VNManager is automatically available as a singleton
# Load and start a story
var story_resource = load("res://addons/gn_vn/samples/demo.story.json")
VisualNovelManager.start_story(story_resource, "start")
```

### Creating a Story

```gdscript
# Create a new story
var story = StoryResource.new()
story.story_data = {
    "meta": {
        "title": "My Visual Novel",
        "version": "1.0.0",
        "author": "Your Name"
    },
    "nodes": [
        {
            "id": "start",
            "type": "dialogue",
            "speaker": "Alice",
            "text": "Hello, world!",
            "next": "choice1"
        },
        {
            "id": "choice1",
            "type": "choice",
            "options": [
                {"text": "Continue", "goto": "next"},
                {"text": "Exit", "goto": "end"}
            ]
        }
    ]
}
```

## 📖 Story JSON Schema

### Dialogue Node
```json
{
    "id": "node_id",
    "type": "dialogue",
    "speaker": "Character Name",
    "text": "Dialogue text with **bold** and *italic* formatting",
    "next": "next_node_id"
}
```

### Choice Node
```json
{
    "id": "node_id",
    "type": "choice",
    "options": [
        {
            "text": "Choice text",
            "goto": "target_node_id",
            "metadata": {}
        }
    ]
}
```

### Variable Node
```json
{
    "id": "node_id",
    "type": "set_variable",
    "variable": "var_name",
    "value": "var_value",
    "next": "next_node_id"
}
```

### Conditional Node
```json
{
    "id": "node_id",
    "type": "conditional",
    "condition": "$var_name == value",
    "true_goto": "true_node_id",
    "false_goto": "false_node_id"
}
```

## 🎯 API Reference

### VNManager (Singleton)

The main class that manages story execution.

```gdscript
# Story control
func start_story(story_resource: StoryResource, entry_point: String = "start") -> void
func show_text(character_id: String, text: String, meta: Dictionary = {}) -> void
func present_choices(choices: Array) -> int

# Save/Load system
func save(slot: int = 0) -> bool
func load_game(slot: int = 0) -> bool
func quicksave() -> void
func quickload() -> void

# Rollback system
func rollback(steps: int = 1) -> void

# Localization
func set_language(lang_code: String) -> void

# Variables
func get_variable(var_name: String) -> Variant
func set_variable(var_name: String, value: Variant) -> void

# Signals
signal story_started(story_title: String)
signal story_ended()
signal text_shown(character_id: String, text: String, metadata: Dictionary)
signal choice_presented(choices: Array)
signal choice_made(choice_index: int, metadata: Dictionary)
signal save_created(slot: int)
signal save_loaded(slot: int)
```

### StoryResource

Resource class for holding story data.

```gdscript
func load_from_json(json_string: String) -> bool
func to_json_string() -> String
func add_node(node_data: Dictionary) -> void
func get_node(node_id: String) -> Dictionary
func get_all_nodes() -> Array
```

### SaveSystem

Handles save/load operations with JSON format.

```gdscript
func save_to_slot(slot: int, save_data: Dictionary) -> bool
func load_from_slot(slot: int) -> Dictionary
func get_save_info(slot: int) -> Dictionary
func delete_slot(slot: int) -> bool
func get_all_saves() -> Array
func export_save(slot: int, export_path: String) -> bool
func import_save(import_path: String, slot: int) -> bool
```

## 🧪 Testing

The plugin includes test scenes:

- `tests/test_save_scene.tscn` - Tests save/load functionality
- `tests/test_dialogue_scene.tscn` - Tests dialogue and choice systems
- `tests/test_comprehensive.tscn` - Comprehensive feature testing

Run these scenes to verify the engine is working correctly.

## 🎨 Editor Integration

The GN_VN Editor Plugin provides:

- **Story Editor Dock**: Visual interface for editing stories
- **Node Tree**: Hierarchical view of story nodes
- **Node Editor**: Property editor for selected nodes
- **Import/Export**: JSON format support

### Using the Editor

1. Open the "GN VN Story Editor" dock
2. Click "New" to create a story
3. Add nodes using the tree view
4. Edit node properties in the node editor
5. Save your story as JSON

## 🔧 Configuration

### Audio Setup

Create audio buses in your project:
- `Voice` - For character voice clips
- `Music` - For background music
- `SFX` - For sound effects

### Localization

Translation files should be placed in `res://addons/gn_vn/localization/`:
- `en.json` - English translations
- `ja.json` - Japanese translations
- etc.

## 🚀 Performance Tips

- Use object pooling for frequently created UI elements
- Optimize audio files for your target platform
- Use compressed textures for character sprites
- Test on target devices for performance validation

## 🤝 Contributing

GN_VN is designed to be extensible. You can:

- Add custom node types by extending the VNManager
- Create custom UI components by inheriting from DialogueBox/ChoiceBox
- Implement custom transitions by extending the Transition system
- Add new localization formats by extending the Localization class

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎯 Roadmap

### Planned Features
- Enhanced editor with visual node graph
- More transition effects
- Advanced audio synchronization
- Mobile-optimized UI
- Cloud save integration
- Advanced localization tools

## 🆚 Comparison with Ren'Py

| Feature | Ren'Py | GN_VN |
|---------|--------|-------|
| Save Format | Pickle (insecure) | JSON (portable) |
| Editor Integration | External | Native Godot |
| Mobile Performance | Poor | Optimized |
| 3D Integration | Limited | Full Node System |
| Rollback | Non-deterministic | Frame-accurate |
| Localization | Basic | JSON Pipeline |
| Testing | Manual | Automated Tests |
| UI Performance | CPU-bound | GPU-accelerated |
| Extensibility | Limited | Plugin API |

## 📞 Support

For questions, bug reports, or feature requests, please open an issue on the project repository.

---

**GN_VN** - A modern Visual Novel Engine for Godot with core features and seamless integration.
