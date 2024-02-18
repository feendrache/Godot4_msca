## The JSON File explained

The Animations are created with the help of a json file, wich includes all definitions needed to create the animation files and the animation tree.

For those interested in how i did this i want to give a small explanation of the parts. 

### Base Informations of the JSON
- name
- version: just to keep track if there are some json updates
- start_animation: to set the start animation inside the animation tree
- nonlayer_bodyparts: definitions of the created layers, when you uncheck the "create layered" in the msca creation process
- bodyparts: definitions of the created layers, when you let the checkbox checked and create all layers
- additional_layers: definitions of the layers that are needed by both versions (nonlayer_bodyparts and bodyparts) like farmer_tools, fishing animations ect.
- animations: definitons of the animations that are created 

### Bodypart/Layer definition
- name of the layer
  - create_track: if a track for this layer should be created in the animation
  - base_spritesheet: if the spritesheet doesn't really change (like the shadow, or the slash animations) it can be preset here and will set the texture of the sprite that represents the layer
  - hframes: horizontal frames the spritesheets provide (set in the animation frames part of the sprite)
  - vframes: vertical frames the spritesheets provide (set in the animation frames part of the sprite)
  - visible: set the initial visibility of the layer when created
  - init_offset: initial offset of the layer when created
  - init_frame: initial frame of the layer when created (only needed when not 0)

### Animations
The animations are created combined from name of the animation plus the direction.
Example: Idle will get four animations: IdleDown, IdleUp, IdleLeft, IdleRight. These are used in the Idle 2DBlendSpace of the animation tree that is created
- name of the animation
- step: size of anim steps used
- loop: is the animation looping?
- loop_type: godot loop type needed (linear mostly, but others are possible)
- timer: times of the frames inside the animation (single times, not added)
- directions: the directions possible for this animation
  - name of the direction
    - tracks: tracks that should be created in this animation
      - frames: the frame numbers used
      - flips: should the sprite be flipped or not
- transitions: animations this animation can transition to in the anim tree (one way, from this anim to the other)
- transition_switch_mode: godot switch mode like "Immediate"
- transition_auto_advance: godot settings if the transition should be automatically
- make_sound: when the animation should emit sound at specific frames
  - frames: on wich frames
  - sound: sound key to be emitted
