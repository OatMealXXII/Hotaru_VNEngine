class_name Transition
extends Node

## Handles transitions between scenes and story states
## Supports crossfade, shader-based, and timeline-based transitions

signal transition_started()
signal transition_finished()

enum TransitionType {
	CROSSFADE,
	FADE_IN,
	FADE_OUT,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	SLIDE_UP,
	SLIDE_DOWN,
	SCALE_IN,
	SCALE_OUT
}

var current_transition: TransitionType = TransitionType.CROSSFADE
var transition_duration: float = 1.0
var transition_easing: Tween.EaseType = Tween.EASE_IN_OUT
var transition_tween: Tween

func _ready():
	transition_tween = Tween.new()
	add_child(transition_tween)

func start_transition(type: TransitionType, duration: float = 1.0) -> void:
	"""Start a transition of the specified type"""
	current_transition = type
	transition_duration = duration
	
	transition_started.emit()
	
	match type:
		TransitionType.CROSSFADE:
			start_crossfade()
		TransitionType.FADE_IN:
			start_fade_in()
		TransitionType.FADE_OUT:
			start_fade_out()
		TransitionType.SLIDE_LEFT:
			start_slide_left()
		TransitionType.SLIDE_RIGHT:
			start_slide_right()
		TransitionType.SLIDE_UP:
			start_slide_up()
		TransitionType.SLIDE_DOWN:
			start_slide_down()
		TransitionType.SCALE_IN:
			start_scale_in()
		TransitionType.SCALE_OUT:
			start_scale_out()

func start_crossfade() -> void:
	"""Start a crossfade transition"""
	# This would implement crossfade logic
	# For now, just emit finished signal after duration
	await get_tree().create_timer(transition_duration).timeout
	transition_finished.emit()

func start_fade_in() -> void:
	"""Start a fade in transition"""
	# This would implement fade in logic
	await get_tree().create_timer(transition_duration).timeout
	transition_finished.emit()

func start_fade_out() -> void:
	"""Start a fade out transition"""
	# This would implement fade out logic
	await get_tree().create_timer(transition_duration).timeout
	transition_finished.emit()

func start_slide_left() -> void:
	"""Start a slide left transition"""
	# This would implement slide left logic
	await get_tree().create_timer(transition_duration).timeout
	transition_finished.emit()

func start_slide_right() -> void:
	"""Start a slide right transition"""
	# This would implement slide right logic
	await get_tree().create_timer(transition_duration).timeout
	transition_finished.emit()

func start_slide_up() -> void:
	"""Start a slide up transition"""
	# This would implement slide up logic
	await get_tree().create_timer(transition_duration).timeout
	transition_finished.emit()

func start_slide_down() -> void:
	"""Start a slide down transition"""
	# This would implement slide down logic
	await get_tree().create_timer(transition_duration).timeout
	transition_finished.emit()

func start_scale_in() -> void:
	"""Start a scale in transition"""
	# This would implement scale in logic
	await get_tree().create_timer(transition_duration).timeout
	transition_finished.emit()

func start_scale_out() -> void:
	"""Start a scale out transition"""
	# This would implement scale out logic
	await get_tree().create_timer(transition_duration).timeout
	transition_finished.emit()

func set_transition_duration(duration: float) -> void:
	"""Set the default transition duration"""
	transition_duration = duration

func set_transition_easing(easing: Tween.EaseType) -> void:
	"""Set the default transition easing"""
	transition_easing = easing

func is_transitioning() -> bool:
	"""Check if a transition is currently running"""
	return transition_tween.is_valid()
