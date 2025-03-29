extends Control

@onready var sanity_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var eye_sprite: AnimatedSprite2D = $MarginContainer/AnimatedSprite2D
var game_over_triggered = false


# Define ranges and corresponding frames [including min, excluding max]
var sanity_frames = [
	{"min": 0.0,  "max": 10.0,  "frame": 0},
	{"min": 10.0, "max": 20.0,  "frame": 1},
	{"min": 20.0, "max": 40.0,  "frame": 2},
	{"min": 40.0, "max": 60.0,  "frame": 3},
	{"min": 60.0, "max": 80.0,  "frame": 4},
	{"min": 80.0, "max": 100.0, "frame": 5}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.stim_collected.connect(on_stim_collected)
	SanityController.instance.sanity_depleting.connect(on_sanity_depleting)
	_on_progress_bar_value_changed(100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	SignalBus.current_stim.emit(sanity_bar.value)

func on_sanity_depleting() -> void:
	sanity_bar.value = SanityController.instance.sanity_value.current_value * 100
	#print(SanityController.instance.sanity_value.current_value, SanityController.instance.current_psychological_effect())
	
	#NOTE Game Over for you, donno where macros wanted this at so update if need be.
	if sanity_bar.value <= 0 and not game_over_triggered:
		print("GameOver")
		SignalBus.game_over.emit()
		game_over_triggered = true

func on_stim_collected() -> void:
	SanityController.instance.apply_stimulant()

func _on_progress_bar_value_changed(value: float) -> void:
	for frame in sanity_frames:
		if value >= frame["min"] and value <= frame["max"]:
			eye_sprite.frame = frame["frame"]
			break
