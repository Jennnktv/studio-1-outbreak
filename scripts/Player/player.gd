extends CharacterBody2D

# @onready var sprite: AnimatedSprite2D = $Sprite

enum State { IDLE, WALK }
var current_state: State = State.IDLE
var target_velocity: Vector2 = Vector2.ZERO

@export var max_speed: float = 600.0
@export var acceleration: float = 2000.0
@export var friction: float = 2500.0

func _ready() -> void:
	SignalBus.stim_collected.connect(on_stim_collected)
	transition_to(State.IDLE)

func _physics_process(delta: float) -> void:
	handle_state(delta)
	move_and_slide()

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
			%AnimationPlayer.stop()
		State.WALK:
			%AnimationPlayer.play("Walk")
			update_rotation()
	
	current_state = new_state

func update_rotation() -> void:
	if velocity.length() > 0.1:
		# Primary directions
		if velocity.x > 0:
			rotation_degrees = 90  # Right
		elif velocity.x < 0:
			rotation_degrees = 270   # Left
		elif velocity.y > 0:
			rotation_degrees = 180    # Down
		elif velocity.y < 0:
			rotation_degrees = 0  # Up
		
		# Diagonal directions
		if velocity.x > 0 && velocity.y < 0:
			rotation_degrees = 45  # Right-Up
		elif velocity.x < 0 && velocity.y < 0:
			rotation_degrees = 315  # Left-Up
		elif velocity.x > 0 && velocity.y > 0:
			rotation_degrees = 135  # Right-Down
		elif velocity.x < 0 && velocity.y > 0:
			rotation_degrees = 225  # Left-Down
	

func on_stim_collected():
	print("Stim collected")
