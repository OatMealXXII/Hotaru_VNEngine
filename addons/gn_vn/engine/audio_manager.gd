class_name AudioManager
extends Node

## Handles audio playback for voice, music, and sound effects
## Provides mixer groups and voice-text synchronization

signal voice_started(audio_stream: AudioStream)
signal voice_finished()
signal music_changed(track_name: String)
signal sound_played(sound_name: String)

# Audio players
var voice_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Audio resources
var voice_clips: Dictionary = {}
var music_tracks: Dictionary = {}
var sound_effects: Dictionary = {}

# Settings
var voice_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8

func _ready():
	setup_audio_players()
	setup_mixer_groups()

func setup_audio_players():
	# Create audio players
	voice_player = AudioStreamPlayer.new()
	voice_player.name = "VoicePlayer"
	add_child(voice_player)
	
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)
	
	# Connect signals
	voice_player.finished.connect(_on_voice_finished)

func setup_mixer_groups():
	# Set up audio bus assignments
	# Use default bus if custom buses don't exist
	voice_player.bus = "Master"
	music_player.bus = "Master"
	sfx_player.bus = "Master"

func play_voice(character_id: String, text: String) -> void:
	##Play voice for a character's text##
	var voice_key = character_id + "_" + str(text.hash())
	
	if voice_clips.has(voice_key):
		var audio_stream = voice_clips[voice_key]
		voice_player.stream = audio_stream
		voice_player.volume_db = linear_to_db(voice_volume)
		voice_player.play()
		voice_started.emit(audio_stream)

func stop_voice() -> void:
	##Stop current voice playback##
	if voice_player.playing:
		voice_player.stop()

func play_music(track_name: String, fade_in: float = 0.0) -> void:
	##Play background music##
	if music_tracks.has(track_name):
		var audio_stream = music_tracks[track_name]
		music_player.stream = audio_stream
		music_player.volume_db = linear_to_db(music_volume)
		music_player.play()
		music_changed.emit(track_name)

func stop_music(fade_out: float = 0.0) -> void:
	##Stop background music##
	if music_player.playing:
		music_player.stop()

func play_sound(sound_name: String) -> void:
	##Play a sound effect##
	if sound_effects.has(sound_name):
		var audio_stream = sound_effects[sound_name]
		sfx_player.stream = audio_stream
		sfx_player.volume_db = linear_to_db(sfx_volume)
		sfx_player.play()
		sound_played.emit(sound_name)

func set_voice_volume(volume: float) -> void:
	##Set voice volume (0.0 to 1.0)##
	voice_volume = clamp(volume, 0.0, 1.0)
	voice_player.volume_db = linear_to_db(voice_volume)

func set_music_volume(volume: float) -> void:
	##Set music volume (0.0 to 1.0)##
	music_volume = clamp(volume, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(volume: float) -> void:
	##Set sound effects volume (0.0 to 1.0)##
	sfx_volume = clamp(volume, 0.0, 1.0)
	sfx_player.volume_db = linear_to_db(sfx_volume)

func load_voice_clip(character_id: String, text: String, audio_path: String) -> void:
	##Load a voice clip for a character's text##
	var voice_key = character_id + "_" + str(text.hash())
	var audio_stream = load(audio_path)
	if audio_stream:
		voice_clips[voice_key] = audio_stream

func load_music_track(track_name: String, audio_path: String) -> void:
	##Load a music track##
	var audio_stream = load(audio_path)
	if audio_stream:
		music_tracks[track_name] = audio_stream

func load_sound_effect(sound_name: String, audio_path: String) -> void:
	##Load a sound effect##
	var audio_stream = load(audio_path)
	if audio_stream:
		sound_effects[sound_name] = audio_stream

func _on_voice_finished():
	##Called when voice playback finishes##
	voice_finished.emit()

func is_voice_playing() -> bool:
	##Check if voice is currently playing##
	return voice_player.playing

func is_music_playing() -> bool:
	##Check if music is currently playing##
	return music_player.playing
