extends CharacterBody2D

const GOLDEN_RATIO = 1.61803398875

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var active_value_moving: ActiveValue = $ActiveValueMoving

enum State { IDLE, WALK }
var current_state: State = State.IDLE
var target_velocity: Vector2 = Vector2.ZERO

@export var animation_speed: float = 3.0
@export var max_speed: float = 600.0
@export var acceleration: float = 2000.0
@export var friction: float = 2500.0

func _ready() -> void:
	SignalBus.stim_collected.connect(on_stim_collected)
	transition_to(State.IDLE)

func _physics_process(delta: float) -> void:
	handle_state(delta)
	move_and_slide()
	animation_player.speed_scale = GOLDEN_RATIO * (acceleration / max_speed) * active_value_moving.current_value

func handle_state(delta: float) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	target_velocity = input_direction * max_speed
	
	match current_state:
		State.IDLE:
			if target_velocity.length() > 0.1:
				transition_to(State.WALK)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
				
		State.WALK:
			if target_velocity.length() < 0.1:
				transition_to(State.IDLE)
			else:
				velocity = velocity.move_toward(target_velocity, acceleration * delta)
				update_rotation()

func transition_to(new_state: State) -> void:
	if new_state == current_state:
		return
	
	# Exit behaviors for current state
	match current_state:
		State.WALK:
			pass  
	
	# Enter new state
	match new_state:
		State.IDLE:
			animation_player.stop()
			active_value_moving.set_value(0.0)
		State.WALK:
			animation_player.play("Walk")
			active_value_moving.set_value(1.0)
			update_rotation()
	
	current_state = new_state

func update_rotation() -> void:
	if velocity.length() > 0.1:
		rotation = velocity.angle()
	

func on_stim_collected():
	Score.bump_stimulants()
