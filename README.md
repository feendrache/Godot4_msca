# MSCA (Mana Seed Character Animator) for Godot 4
Welcome to the MSCA for Godot 4. 

!!Please be aware that this plugin is created to work with the newest Version of Godot 4!!
I don't plan to backport any of it to Godot 3, just to let you know.

Currently the following ManaSeed Sprite systems are supported:
- Farmer Sprite System

The JSON file for the old Character Base is still included, but i haven't implemented it into the MSCA yet, since i only use the Farmer Sprite System right now.

The Farmer Sprite System provides a vast range of animations and creating all these animations inside the animation player of godot is a LOT of work, especially for a layered sprite system, so i created a tool that not only gives you a layered Sprite set up, but also all animations in an animation player and a complete animation tree inside godot. 

Next to the creation of the Player (or NPC) Node and all animations the msca also includes a shader, with wich you can use color ramps Seliel provided inside the Sprite System.

I will try to explain the MSCA to you in the following pages:
- [How to create the Player Node (quickstart)](/docs/quickstart.md)
- [The JSON explained](/docs/jsons_explained.md)
- [Explanation of the created Node](/docs/player_node.md)
- Provided Classes
  - MSCAPlayer
  - Movement Class
  - MSCAFarmerSpriteLayers
  - MSCAPaletteSwaps
- The Plaette Swap Shader
