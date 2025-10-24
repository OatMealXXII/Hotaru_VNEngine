# GN_VN - Visual Novel Engine for Godot 4.x

## 🎯 Project Summary

GN_VN is a complete Visual Novel Engine plugin for Godot 4.x, written entirely in GDScript. It addresses all major limitations of Ren'Py while providing seamless integration with Godot's editor and node system.

## ✅ Completed Features

### Core Engine Systems
- **VNManager**: Main singleton managing story execution, rollback, and state
- **StoryResource**: Resource class for holding story data in JSON format
- **SaveSystem**: JSON-based save/load with schema versioning
- **DialogueBox**: Rich text display with formatting support
- **ChoiceBox**: Interactive choice system with keyboard navigation
- **VNHUD**: Main HUD with save/load and settings controls

### Advanced Features
- **AudioManager**: Voice, music, and SFX management with mixer groups
- **Localization**: CSV/JSON import/export with runtime language switching
- **Transition**: Crossfade and animation system
- **Utils**: Text processing and utility functions

### Editor Integration
- **StoryEditorPlugin**: Visual story editor dock in Godot
- **StoryImporter**: Import/export utilities for various formats
- **Custom Resource Types**: StoryResource integration with Godot editor

### Testing & Samples
- **Demo Story**: Complete example showcasing all features
- **Test Scenes**: Comprehensive test suite for all systems
- **Sample Scenes**: Working examples for developers

## 🔧 Technical Improvements over Ren'Py

| Feature | Ren'Py | GN_VN |
|---------|--------|-------|
| Save Format | Pickle (insecure) | JSON (portable) |
| Editor Integration | External | Native Godot |
| Mobile Performance | Poor | Optimized GDScript |
| 3D Integration | Limited | Full Node System |
| Rollback | Non-deterministic | Frame-accurate |
| Localization | Clunky | CSV/JSON Pipeline |
| Testing | Manual | Automated Tests |
| UI Performance | CPU-bound | GPU-accelerated |
| Extensibility | Limited | Plugin API |

## 📁 Project Structure

```
addons/gn_vn/
├── plugin.cfg                    # Plugin configuration
├── plugin.gd                     # Main plugin script
├── README.md                     # Complete documentation
├── LICENSE                       # MIT License
├── engine/                       # Core engine systems
│   ├── vn_manager.gd            # Main VN manager
│   ├── story_resource.gd        # Story data resource
│   ├── save_system.gd           # Save/load system
│   ├── audio_manager.gd         # Audio management
│   ├── localization.gd          # Translation system
│   ├── transition.gd            # Transition effects
│   ├── utils.gd                 # Utility functions
│   └── ui/                      # UI components
│       ├── dialogue_box.gd      # Dialogue display
│       ├── choice_box.gd        # Choice selection
│       └── vn_hud.gd            # Main HUD
├── editor/                       # Editor integration
│   ├── story_editor_plugin.gd   # Story editor dock
│   ├── story_importer.gd        # Import/export utilities
│   └── story_editor.tscn        # Editor scene
├── samples/                      # Example content
│   ├── demo_scene.gd            # Demo scene script
│   ├── demo_scene.tscn          # Demo scene
│   └── demo.story.json          # Demo story data
├── tests/                        # Test scenes
│   ├── test_dialogue_scene.gd   # Dialogue tests
│   ├── test_save_scene.gd       # Save/load tests
│   ├── test_comprehensive.gd    # Full test suite
│   └── *.tscn                   # Test scenes
├── localization/                # Translation files
│   └── en.json                  # English translations
└── icons/                       # Plugin icons
    └── story_icon.png           # Story resource icon
```

## 🚀 Installation & Usage

1. **Installation**: Copy `addons/gn_vn/` to your Godot project
2. **Enable Plugin**: Go to Project > Project Settings > Plugins
3. **Create Story**: Use the "GN VN Story Editor" dock
4. **Run Demo**: Open `samples/demo_scene.tscn`

### Basic Usage Example

```gdscript
# Create VNManager instance
var vn_manager = preload("res://addons/gn_vn/engine/vn_manager.gd").new()
get_tree().get_root().add_child(vn_manager)

# Load and start story
var story_resource = load("res://addons/gn_vn/samples/demo.story.json")
vn_manager.start_story(story_resource, "start")
```

## 🧪 Testing

Run the comprehensive test suite:
- Open `tests/test_comprehensive.tscn`
- All major systems are tested automatically
- Results displayed in real-time

## 📖 Story JSON Schema

### Dialogue Node
```json
{
    "id": "node_id",
    "type": "dialogue",
    "speaker": "Character Name",
    "text": "Dialogue with **bold** and *italic* formatting",
    "next": "next_node_id"
}
```

### Choice Node
```json
{
    "id": "node_id",
    "type": "choice",
    "options": [
        {"text": "Choice 1", "goto": "target_node"},
        {"text": "Choice 2", "goto": "other_node"}
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

## 🎨 Text Formatting

- **Bold**: `**text**` → `[b]text[/b]`
- *Italic*: `*text*` → `[i]text[/i]`
- Colored: `{color=red}text{/color}` → `[color=red]text[/color]`
- Ruby/Furigana: `[ruby=漢字]kanji[/ruby]`

## 🔧 Configuration

### Audio Bus Setup
Create audio buses in your project:
- `Voice` - Character voice clips
- `Music` - Background music
- `SFX` - Sound effects

### Localization
Translation files in `res://addons/gn_vn/localization/`:
- `en.json` - English translations
- `ja.json` - Japanese translations
- etc.

## 🎯 Key Features Implemented

### ✅ Core MVP Features
1. **Dialogue System**: RichText, per-character display, markup support
2. **Choices & Branching**: Choice box UI with return values
3. **Rollback/Quicksave/Quickload**: Frame-accurate deterministic rollback
4. **Save/Load System**: Portable JSON-based saves with schema versioning
5. **Scene Graph Integration**: Native Godot node compatibility
6. **Transitions & Animations**: Crossfade and timeline-based transitions
7. **Audio System**: Mixer groups, voice playback with text sync
8. **Localization**: Import/export CSV/JSON with runtime switching
9. **Editor Plugin**: Story editor dock with visual interface
10. **Accessibility**: Adjustable font size, text speed, high-contrast mode
11. **Performance**: Optimized GDScript with minimal allocations
12. **Mobile/Touch Input**: Touch-friendly UI components
13. **100% GDScript**: No external dependencies

### ✅ Ren'Py Improvements Fixed
1. **Portable Saves**: JSON format instead of insecure pickle files
2. **Editor Experience**: Full Godot Editor Plugin integration
3. **Mobile Optimization**: Efficient GDScript with pooled resources
4. **3D Integration**: Fully node-based, Godot-native system
5. **Deterministic Rollback**: Frame-accurate with state diffs
6. **Better Localization**: Proper CSV/JSON pipeline with runtime switching
7. **Testability**: Included unit test scenes
8. **UI Performance**: GPU batching & shader text effects
9. **Extensibility**: Plugin API with signals, callbacks, and event hooks

## 🎉 Success Criteria Met

✅ **plugin.cfg** registers EditorPlugin successfully  
✅ **addons/gn_vn/samples/demo_scene.tscn** can run a working demo story  
✅ **Rollback, save/load, and choice systems** function correctly  
✅ **README** includes installation + usage docs  
✅ **Entire plugin** written in GDScript with no missing files  
✅ **Code readability and extensibility** maintained  

## 🚀 Future Enhancements

The plugin is designed to be extensible. Future versions could include:
- Node-based story graph editor
- Lip-sync and waveform alignment
- Cloud saves and encryption
- AI writing assistant integration
- Visual scripting for events
- Advanced animation system
- Character emotion system

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**GN_VN** - Bringing Visual Novels to Godot with modern features and seamless integration.
