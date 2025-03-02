class_name ActiveValue extends Node
## A utility class for managing and interpolating a value within a defined range.
##
## This class is useful for smoothly transitioning between values (e.g., health bars, progress indicators)
## and provides helper methods for value manipulation, normalization, and bounds checking.
##
## Signals are emitted when the value changes, reaches its target, or exceeds its bounds.

#region properties
var target_value: float = 0.0
## The value that `current_value` is interpolating towards.
#endregion

#region exports

@export var label: String = "Value"
## A descriptive label for this value (e.g., "Health", "Progress").

@export var min_value: float = 0.0
## The minimum allowed value for `current_value` and `target_value`.

@export var max_value: float = -1.0
## The maximum allowed value for `current_value` and `target_value`.
## If set to -1, there is no upper limit.

@export var current_value: float = 0.0
## The current interpolated value. This is updated in `_process` when `is_active` is true.

@export var lerp_weight: float = 0.1
## The interpolation weight used to smoothly transition `current_value` towards `target_value`.
## Must be between 0.0 and 1.0.

@export var is_active: bool = true
## If true, `current_value` will interpolate towards `target_value` in `_process`.

#endregion

#region signals
signal value_changed(value: float)
## Emitted whenever `current_value` changes during interpolation.

signal value_reached_target(value: float)
## Emitted when `current_value` reaches `target_value`.

signal value_exceeded_max(value: float)
## Emitted when `current_value` exceeds `max_value`.

signal value_fell_below_min(value: float)
## Emitted when `current_value` falls below `min_value`.
#endregion

#region public methods

## Sets the `target_value` to the provided value, clamped between `min_value` and `max_value`.
func set_value(value: float) -> void:
	target_value = clamp(value, min_value, max_value)
	_check_value_bounds()

## Returns the current interpolated value.
func get_value() -> float:
	return current_value

## Returns the current interpolated value as an integer.
func get_int_value() -> int:
	return int(current_value)

## Returns the remainder of `current_value` divided by `mod` (floating-point).
func get_modulate_by(mod: float) -> float:
	return fmod(current_value, mod)

## Returns the remainder of `current_value` divided by `mod` (integer).
func get_modulate_by_int(mod: int) -> int:
	return int(fmod(current_value, float(mod)))

## Activates interpolation. `current_value` will start moving towards `target_value`.
func activate() -> void:
	is_active = true

## Deactivates interpolation. `current_value` will stop updating.
func deactivate() -> void:
	is_active = false

## Resets `target_value` to `min_value`.
func reset_to_min() -> void:
	set_value(min_value)

## Resets `target_value` to `max_value`.
func reset_to_max() -> void:
	set_value(max_value)

## Increases `target_value` by the specified amount.
func increment(amount: float) -> void:
	set_value(target_value + amount)

## Decreases `target_value` by the specified amount.
func decrement(amount: float) -> void:
	set_value(target_value - amount)

## Returns `true` if `current_value` is approximately equal to `min_value`.
func is_at_min() -> bool:
	return is_equal_approx(current_value, min_value)

## Returns `true` if `current_value` is approximately equal to `max_value`.
func is_at_max() -> bool:
	return is_equal_approx(current_value, max_value)

## Returns `true` if `current_value` is approximately equal to `target_value`.
func is_at_target() -> bool:
	return is_equal_approx(current_value, target_value)

## Returns the normalized value of `current_value` between `min_value` and `max_value`.
## If `min_value` and `max_value` are equal, returns 0.0.
func normalize_value() -> float:
	if max_value == min_value:
		return 0.0
	return (current_value - min_value) / (max_value - min_value)

## Updates the interpolation weight (`lerp_weight`). Clamps the value between 0.0 and 1.0.
func set_lerp_weight(new_weight: float) -> void:
	lerp_weight = clamp(new_weight, 0.0, 1.0)

## Updates the `min_value` and re-clamps `target_value` to the new range.
func set_min_value(new_min: float) -> void:
	min_value = new_min
	set_value(target_value)  # Re-clamp the target value

## Updates the `max_value` and re-clamps `target_value` to the new range.
func set_max_value(new_max: float) -> void:
	max_value = new_max
	set_value(target_value)  # Re-clamp the target value

## Checks if `current_value` exceeds `max_value` or falls below `min_value` and emits signals accordingly.
func _check_value_bounds() -> void:
	if current_value >= max_value:
		value_exceeded_max.emit(current_value)
	elif current_value <= min_value:
		value_fell_below_min.emit(current_value)
#endregion

#region override methods

func _process(_delta: float) -> void:
	if is_active:
		current_value = lerp(current_value, target_value, lerp_weight)
		value_changed.emit(current_value)
		
		if is_at_target():
			value_reached_target.emit(current_value)

#endregion
