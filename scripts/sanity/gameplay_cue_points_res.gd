class_name GameplayCuePoints extends CuePoints

enum GameplayImpact {
	DELAYED_INPUTS,   # Delayed player inputs
	ERRATIC_MOVEMENT, # Erratic or unpredictable movement
	FORCED_ACTIONS    # Forced actions on the player
}

@export var element: GameplayImpact
