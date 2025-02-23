extends Control

@onready var sanity_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var fury_time: Timer = $FuryTime
var sanity:float
var sanity_loss = 0.05


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.stim_collected.connect(on_stim_collected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	sanity = sanity_bar.value
	
	SignalBus.current_stim.emit(sanity)
	if sanity <= 50:
		is_withdrawal()
	
	if sanity < 1:
		is_dead()
	
	if sanity > 99:
		is_fury()
		


func is_withdrawal() -> void:
	pass #Implement effects here


func is_dead() -> void:
	pass #Implement death


func is_fury() -> void:
	#Implement fury mode here
	fury_time.start()
	sanity_loss = 0.1


func on_stim_collected() -> void:
	sanity_bar.value += 5


func _on_sanity_loss_timeout() -> void:
	sanity_bar.value -= sanity_loss


func _on_fury_time_timeout() -> void:
	sanity_loss = 0.05
