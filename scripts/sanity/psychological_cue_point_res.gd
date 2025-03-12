class_name PsychologicalCuePoint extends CuePoints

enum PsychologicalHorrorElements {
	WITHDRAWAL_EFFECTS,  		# Triggered when stims are not found and sanity is low
	VISUAL_BLURRING,     		# Blurring effect
	VISUAL_FLICKERING,   		# Flickering effect
	VISUAL_COLOR_SHIFTS, 		# Color shifts
	HALLUCINATING_OBSTACLES,   # Hallucinating obstacles that might not exist
	AUDIO_WHISPERS,      	   # Whispering sounds
	AUDIO_EERIE_SOUNDS,  	   # Eerie ambient sounds
	AUDIO_FOOTSTEPS      	   # Footstep sounds
}

@export var element: PsychologicalHorrorElements
