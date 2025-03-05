extends Control

@onready var sanity_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var fury_time: Timer = $FuryTime
@onready var eye_sprite: AnimatedSprite2D = $MarginContainer/AnimatedSprite2D

var sanity:float
var sanity_loss = 0.05


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.stim_collected.connect(on_stim_collected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	sanity = sanity_bar.value
	
	SignalBus.current_stim.emit(sanity)
	if sanity < 1:
		is_dead()
	
	if sanity >= 1 and sanity < 10:
		eye_sprite.frame = 0
	
	if sanity >= 10 and sanity < 20:
		eye_sprite.frame = 1
		
	if sanity >= 20 and sanity < 40:
		eye_sprite.frame = 2
	
	if sanity >= 40 and sanity < 60:
		eye_sprite.frame = 3
		
	if sanity <= 50:
		is_withdrawal()
	
	if sanity >= 60 and sanity < 80:
		eye_sprite.frame = 4
	
	if sanity >= 80 and sanity <= 99:
		eye_sprite.frame = 5
	
	if sanity > 99:
		is_fury()
		eye_sprite.frame = 6


func is_withdrawal() -> void:
	pass #Implement effects here


func is_dead() -> void:
	pass #Implement death


func is_fury() -> void:
	#Implement fury mode here
	fury_time.start()
	sanity_loss = 0.1


func on_stim_collected() -> void:
	sanity_bar.value += 20


func _on_sanity_loss_timeout() -> void:
	sanity_bar.value -= sanity_loss


func _on_fury_time_timeout() -> void:
	sanity_loss = 0.05
