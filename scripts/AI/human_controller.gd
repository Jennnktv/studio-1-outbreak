class_name HumanController extends Node

@export var state_machine: StateMachine
@export var configuration: HumanConfigurationResource

@onready var navigator: NavigationAgent2D = $NavigationAgent
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var sensors: Node2D = $Sensors

var raycasts: Array[RayCast2D] = []

func _ready():
	for i in range(-5, 5):
		var raycast = RayCast2D.new()
		var distance = configuration.view_distance
		raycast.target_position = Vector2(distance, 0)
		raycast.rotation_degrees = i * 10
		raycast.enabled = true
		sensors.add_child(raycast)
		raycasts.append(raycast)
		
