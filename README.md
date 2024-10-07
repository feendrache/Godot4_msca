This Documentation is found at: https://github.com/feendrache/Godot4_msca
# MSCA (Mana Seed Character Animator) for Godot 4
Welcome to the MSCA for Godot 4. 

__Please be aware that this plugin is created to work with the Godot 4.3__

I don't plan to backport any of it to Godot 3, just to let you know.

## Disclaimer
I made this plugin mainly for my game. With manipulating the JSON file i have an easy way to recreate the whole Node again and again without having to recreate all the anims per hand. 

With this in mind please be aware that it won't fit everyone and was never intended to do so. It mainly presents a way of how to do it.

The Setup of all animations happen in the json file, so when you want to adjust the Settings of the animations like timers or stuff, please visit there and feel free to adjust them, but be aware that an update will overwrite this json again.

You can edit the animations themselves right inside the AnimationPlayer node in the editor after you created the Player. But if you want your changes to be present every time you recreate the node, you'll need to edit the JSON directly.

if you want to help me a bit, you can support me at KoFi: 

<a href='https://ko-fi.com/F1F1BJIJL' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi4.png?v=3' border='0' alt='Support me at ko-fi.com' /></a>

## Description
Currently the following ManaSeed Sprite systems are supported:
- [Farmer Sprite System](https://seliel-the-shaper.itch.io/farmer-base)
  
<a href="https://seliel-the-shaper.itch.io/farmer-base" target="_blank"><img src="https://github.com/feendrache/Godot4_msca/assets/33016907/4a15f9d3-8190-4d47-8e70-786824704491" width="400"/></a>

*Image used with permission of Seliel the Shaper*

The JSON file for the old Character Base is still included, but i haven't implemented it into the MSCA yet, since i only use the Farmer Sprite System right now.

The Farmer Sprite System provides a vast range of animations and creating all these animations inside the animation player of godot is a LOT of work, especially for a layered sprite system, so i created a tool that not only gives you a layered Sprite set up, but also all animations in an animation player and a complete animation tree inside godot. 

Next to the creation of the Player (or NPC) Node and all animations the msca also includes a shader, with wich you can use color ramps Seliel provided inside the Sprite System.

I will try to explain the MSCA to you in the following pages:
- [Install and Quickstart](/docs/quickstart.md)
- [The JSON explained](/docs/jsons_explained.md)
- [Explanation of the created Node](/docs/player_node.md)
- Provided Classes
  - [MSCAPlayer](docs/MSCAPlayer.md)
  - [Movement Class](docs/movement.md)
  - [MSCAFarmerSpriteLayers](docs/MSCAFarmerSpriteLayers.md)
  - [MSCAPaletteSwaps](docs/MSCAPaletteSwaps.md)
- [The Plaette Swap Shader](docs/paletteShader.md)
- [Test-Scene](docs/TestScene.md)

## DevLog
### 1.0.1
- minor Bugfix for fishing anim
### 1.0.0
- updates for 4.3 compability
### 0.9.6
- small changes for better understanding
### 0.9.5
- added some stuff to show how i did it in the test scene, commented the code of the test scene to make it better understandable
**
