class_name HumanStateBase extends StateNode

@export var configuration: HumanConfigurationResource
@export var body: CharacterBody2D
@export var navigator: NavigationAgent2D
@export var sprite: AnimatedSprite2D
@export var sensors: Node2D

func navigate(speed: float) -> void:
	body.velocity = (navigator.get_next_path_position() - body.global_position).normalized() * speed
	body.rotation = lerp_angle(body.rotation, body.velocity.angle(), 0.1)
	body.move_and_slide()

func transition_to_normal():
	state_machine.change_state("Normal")

func transition_to_panic():
	state_machine.change_state("Panic")

func get_raycasts() -> Array[RayCast2D]:
	var raycasts: Array[RayCast2D] = []
	for sensor in sensors.get_children():
		if sensor is RayCast2D:
			raycasts.append(sensor)
	return raycasts

func get_raycast_collider_from_group(group: String) -> Array[Node2D]:
	var colliders: Array[Node2D] = []
	for raycast in get_raycasts():
		if raycast.is_colliding() and raycast.get_collider().is_in_group(group):
				colliders.append(raycast.get_collider())
	return colliders

func is_player_on_sight() -> bool:
	var colliders: Array[Node2D] = get_raycast_collider_from_group("player")
	return colliders.size() > 0

func is_human_panic_on_sight() -> bool:
	var colliders: Array[Node2D] = get_raycast_collider_from_group("human")
	for collider in colliders:
		var human = collider as HumanController
		if human.is_current_state_panic():
			return true
	return colliders.size() > 0

func get_stims_on_sight() -> Array[Node2D]:
	var colliders: Array[Node2D] = get_raycast_collider_from_group("stims")
	return colliders

func is_stims_on_sight() -> bool:
	return get_stims_on_sight().size() > 0
