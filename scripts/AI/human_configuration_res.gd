class_name HumanConfigurationResource extends Resource

const GOLDEN_RATIO = 1.61803398875
const METER = 32.0

@export var walking_speed: float = METER * GOLDEN_RATIO * 2
@export var running_speed: float = METER * GOLDEN_RATIO * 8
@export var view_distance: float = METER * 10
@export var stim_radius: float = METER * 4
