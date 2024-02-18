## The created player node

The MSCA will create either a full layered Player Node:

![grafik](https://github.com/feendrache/Godot4_msca/assets/33016907/1941969f-54eb-41e4-a673-f347ca439bed)

Or one with "only" the body Layer for the actual Player Sprites.

![grafik](https://github.com/feendrache/Godot4_msca/assets/33016907/36c7f55f-af5a-4f3a-8b18-1ba09b4527f6)

In the full layered version, the following layers need to be filled with the spritesheets in the corresponding folders inside the base sheets of the Sprite System:

![grafik](https://github.com/feendrache/Godot4_msca/assets/33016907/9c13a50b-e88b-4e11-beb8-40d6cafaa2af)

for better understanding the layers are named like the folders. 

In the smaller version you need to set the 01body with the prebaked Sprite you have created (maybe with the FarmerSprite Customizer)

The following layers are "outside" the layer structure provided by the base sheet folders:
- shadow: it contains the spritesheet with the shadow provided by the Sprite System (farmer_base_effects/farmer props 32x32 v00.png)
- mount_bottom: mounts need to be below the player when ridden (this layer may be removed later since the mount node can be displayed behind the player and this layer may not be really needed)
- farmer_tools: the layer for the tool spritesheet the character uses in the animations (farmer_base_effects/farmer tool xxx.png)
- farmer_props: spritesheet with music instruments and stuff (farmer_base_effects/farmer props 32x32 v00.png)
- farmer_1h_weapon: this is where the weapon spritesheet will go (farmer_base_effects/famer 1hwpn xxx 32x32 v00.png)
- farmer_bow: this is where a bow spritesheet should go (farmer_base_effects/farmer bow xxx 32x32 v00.png)
- fishing_right_left: fishing animations (farmer_base_effects/fishing effects(right, left) 112x64 v00.png)
- fishing_up_down: fishing animations (farmer_base_effects/fishing effects(up, down) 64:96 v00.png)
- 32x32_anims: contains animated stuff for actions like watering, drinking, planting smithing, notes for music (farmer_base_effects/farmer animations 32x32 v00.png)
- 64x64_anims: contains animated stuff for actions like reaping and the bug net (farmer_base_effects/farmer animations 64x64 v00.png)
- slash_effects: contains the slash anims (farmer_base_effects/farmer slash effects 64x64 v00.png)
- mount_top: the head of the mounts needs to be on top of the character, so when mounting up the head of the mount should be mirrored here

### Notes
- The visibility of layers is not set within the animations, that needs to be done via code (example: when sitting down in a chair the shadow needs to be hidden)
- You cannot use the Ramp-Shader in the smaller version, only in the full layered version
- Some stuff like the position and rotation of the weapons need to be set via code and are not part of the animation itself
