extends Control

@onready var sanity_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var fury_time: Timer = $FuryTime
@onready var eye_sprite: AnimatedSprite2D = $MarginContainer/AnimatedSprite2D

@export var loss_rate: float = 0.05

var is_furious: bool = false

var sanity_loss: float:
	get:
		return 0.0 if is_furious else loss_rate

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	SignalBus.current_stim.emit(sanity_bar.value)

func is_withdrawal() -> void:
	pass #Implement effects here

func is_dead() -> void:
	SignalBus.game_over.emit()


func is_fury() -> void:
	#Implement fury mode here
	fury_time.start()
	is_furious = true

func on_stim_collected() -> void:
	sanity_bar.value += 20

func _on_sanity_loss_timeout() -> void:
	sanity_bar.value -= sanity_loss

func _on_fury_time_timeout() -> void:
	is_furious = false

func _on_progress_bar_value_changed(value: float) -> void:
	# Godot handles automatic clamping to be in range of 0 ~ 100 defined in inspector
	# check for the various things that happen when sanity reaches thresholds
	# fury when sanity >= 100
	# game over state when sanity <= 0
	if value >= 100.0:
		is_fury()
		eye_sprite.frame = 6
		return
	elif value <= 0.0:
		is_dead()
		eye_sprite.frame = 0
		return
		
	if value <= 50.0:
		is_withdrawal()

	# Find the appropriate sprite frame
	for mapping in sanity_frames:
		if value >= mapping["min"] and value < mapping["max"]:
			eye_sprite.frame = mapping["frame"]
			break
