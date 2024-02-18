## The JSON File explained

The Animations are created with the help of a json file, wich includes all definitions needed to create the animation files and the animation tree.

For those interested in how i did this i want to give a small explanation of the parts. 

### Base Informations of the JSON
- name
- version: just to keep track if there are some json updates
- start_animation: to set the start animation inside the animation tree
- nonlayer_bodyparts: the created layers, when you uncheck the "create layered" in the msca creation process
- bodyparts: the created layers, when you let the checkbox checked and create all layers

### Bodypart (Layer definition)
- name of the layer
  - create_track: if a track for this layer should be created in the animation
  - base_spritesheet: if the spritesheet doesn't really change (like the shadow, or the slash animations) it can be preset here and will set the texture of the sprite that represents the layer
  - hframes: horizontal frames the spritesheets provide (set in the animation frames part of the sprite)
  - 
