@tool
extends VBoxContainer

var animationPlayer = null
var animationTree = null
var spriteLayers = null
var blendNodes = []

var character_base = preload("res://addons/msca/packs/character_base.gd").new()
var farmer_base = preload("res://addons/msca/packs/farmer_base.gd").new()

func _on_CreatePlayer_button_pressed():
	var root =  get_tree().get_edited_scene_root()
	var playerNode = CharacterBody2D.new()
	var base_path = $BasePath.text
	var create_sprite_layers = $UseLayeredSpritesCheckButton.button_pressed
	
	match $PackSelection.selected:
		0:
			farmer_base.create_from_farmer_base(root, playerNode, base_path, create_sprite_layers)
		1:
			character_base.create_from_character_base(root, playerNode, base_path)
