extends Node
class_name nav_component_properties

###########################################
# Properties
###########################################
#E3C

var room_centers: Array = []
#var tile_map: TileMapLayer

@export_category("/////////////////////////////////////////")
@export_group("Debug Path")
@export var is_debug: bool = false:
	get: return _is_debug
	set(value): _is_debug = value
var _is_debug: bool = false

@export_group("Player Target")
@export var player: CharacterBody2D = null:
	get: return _player
	set(newPlayer): _player = newPlayer
var _player: CharacterBody2D = null

@export_group("Status")
@export var is_infected: bool = false:
	get: return _is_infected
	set(value): _is_infected = value
var _is_infected: bool = false

@export_group("Timers")
@export_range(0, 100, 0.1) var death_timer: float = 60.0:
	get: return _death_timer
	set(value): _death_timer = snapped(clamp(value, 0, 100), 0.1)
var _death_timer: float = 60.0

@export_range(0, 10, 0.1) var wander_transition_time: float = 1.0:
	get: return _wander_transition_time
	set(value): _wander_transition_time = snapped(clamp(value, 0, 10), 0.1)
var _wander_transition_time: float = 1.0

@export_range(0, 10, 0.1) var flee_transition_time: float = 0.1:
	get: return _flee_transition_time
	set(value): _flee_transition_time = snapped(clamp(value, 0, 10), 0.1)
var _flee_transition_time: float = 0.1

@export_range(0, 10, 0.1) var infected_transition_time: float = 0.5:
	get: return _infected_transition_time
	set(value): _infected_transition_time = snapped(clamp(value, 0, 10), 0.1)
var _infected_transition_time: float = 0.2

@export_range(0, 10, 0.1) var search_transition_time: float = 2.0:
	get: return _search_transition_time
	set(value): _search_transition_time = snapped(clamp(value, 0, 10), 0.1)
var _search_transition_time: float = 2.0

@export_group("Movement Speed")
@export_range(0, 1000, 0.1) var wander_speed: float = 100:
	get: return _wander_speed
	set(value): _wander_speed = snapped(clamp(value, 0, 1000), 0.1)
var _wander_speed: float = 100

@export_range(0, 1000, 0.1) var infected_speed: float = 200:
	get: return _infected_speed
	set(value): _infected_speed = snapped(clamp(value, 0, 1000), 0.1)
var _infected_speed: float = 200

@export_range(0, 1000, 0.1) var flee_speed: float = 450:
	get: return _flee_speed
	set(value): _flee_speed = snapped(clamp(value, 0, 1000), 0.1)
var _flee_speed: float = 450

@export_group("FOV")
@export_range(0, 1000, 5) var flee_distance_min: float = 300:
	get: return _flee_distance_min
	set(value): _flee_distance_min = snapped(clamp(value, 0, 1000), 5)
var _flee_distance_min: float = 100

@export_range(0, 2000, 5) var flee_distance_max: float = 2000:
	get: return _flee_distance_max
	set(value): _flee_distance_max = snapped(clamp(value, 0, 2000), 5)
var _flee_distance_max: float = 2000

@export_range(0, 50, 0.5) var infection_distance: float = 25:
	get: return _infection_distance
	set(value): _infection_distance = snapped(clamp(value, 0, 50), 0.5)
var _infection_distance: float = 25

@export_group("Flee AI Behavior")
@export_range(0, 1000, 0.5) var escape_radius: float = 200:
	get: return _escape_radius
	set(value): _escape_radius = snapped(clamp(value, 0, 1000), 0.5)
var _escape_radius: float = 50

@export_range(0, 1000, 0.5) var escape_angle_step: float = 45:
	get: return _escape_angle_step
	set(value): _escape_angle_step = snapped(clamp(value, 0, 1000), 0.5)
var _escape_angle_step: float = 45

@export_range(0, 1000, 0.5) var safe_distance: float = 65:
	get: return _safe_distance
	set(value): _safe_distance = snapped(clamp(value, 0, 1000), 0.5)
var _safe_distance: float = 65

# base timer cooldowns
var cooldowns: Dictionary = {} 
func start_cooldown(action: String, duration: float):
	cooldowns[action] = duration
func is_on_cooldown(action: String) -> bool:
	return cooldowns.get(action, 0) > 0
	
func cycle_timer_cooldowns(_delta: float):
	#cycle our cooldowns
	for action in cooldowns.keys():
		#count down
		cooldowns[action] -= _delta
		if cooldowns[action] <= 0:
			#remove the ones that are 0
			cooldowns.erase(action) 
