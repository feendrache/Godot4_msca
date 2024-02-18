## The Layer Container / MSCAFarmerSpriteLayers

In this class the basic layer handling is managed.

### Signals
the following signals are provided:
- animation_state_finished(state_name, state_duration)
- animation_state_started(state_name)
- animation_set_hitbox(counter, track, timer_value, direction)
- make_sound(state_name, sound_name)
All these Signals are triggered by functions called out of the animations

### animation_state_finished
This signal is fired when an animation state (like jumping) is finished and provides the name of the finished state and the duration the state has (animation length)

### animation_state_started
This signal is fired at the start of an animation state

### animation_set_hitbox
This signal is fired inside the attack animations to provide you with a way on setting the hitboxes of your weapon
