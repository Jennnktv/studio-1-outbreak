extends Node
@warning_ignore("unused_signal") signal stim_collected
@warning_ignore("unused_signal") signal map_generated
@warning_ignore("unused_signal") signal current_stim(value:float)

@warning_ignore("unused_signal") signal camera_zoom_change(value:float)

@warning_ignore("unused_signal") signal game_over
@warning_ignore("unused_signal") signal game_over_score_reset # NOTE

@warning_ignore("unused_signal") signal human_changed_to_infect(human: HumanController)
@warning_ignore("unused_signal") signal human_changed_to_panic(human: HumanController)
@warning_ignore("unused_signal") signal human_changed_to_normal(human: HumanController)
