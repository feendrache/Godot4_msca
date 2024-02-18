class_name MSCASpriteLayers
extends Node2D

signal animation_state_finished(state_name)

#set to the path of your Spritesheets
@export var spritesheet_path: String # (String, DIR)
#variable to set the new spritesheet page for the animation
@export var spritesheet_page: String = "p1"
#currently used spritesheet page
var current_spritesheet_page = "p1"

func _ready():
	#at the start the current and the new page are the same
	current_spritesheet_page = spritesheet_page

func _process(delta):
	#check if the spritesheet page changed
	if (current_spritesheet_page != spritesheet_page):
		#if changed change the textures of the layers
		change_spritesheets(spritesheet_page)

#for render order in animations
#tla_pos and tlb_pos are arguments set inside the animations when it calls this function
func change_child_position(tla_pos, tlb_pos):
	#get the node of the main hand
	var tla = self.get_node("6tla")
	#if there is a node for it and you got a new position, move the tla to this position
	if (tla_pos != null && tla != null): self.move_child(tla, tla_pos)
	#get the node of the unchecked hand
	var tlb = self.get_node("7tlb")
	#if there is a node for it and you got a new position, move the tlb to this position
	if (tlb_pos != null && tlb != null): self.move_child(tlb, tlb_pos)

#changes the texture of all layers to the newly set spritesheet page
func change_spritesheets(new_page):
	#iterate through all the child nodes insede the SpriteLayers
	for child_sprite in self.get_children():
		#if the child is a sprite it is one of the layers of the player
		# not for 6tla and 7tlb
		if child_sprite is Sprite2D && child_sprite.name != "6tla" && child_sprite.name != "7tlb":
			#store the currently used texture
			var current_spritesheet = child_sprite.texture
			#store the possible subfolder to access the texture
			var subfolder = false
			#check if there is a new spritesheet available
			var new_spritesheet = false
			#if there is currently a texture/spritesheet set
			if current_spritesheet != null:
				#split the path up the get the parts of the path seprated
				var splitted = current_spritesheet.load_path.split(".")
				#get the real path
				splitted = splitted[1].split("/")
				#split the spritesheet name in its part
				splitted = splitted[2].split("_")
				#splitted[2] is the page number (p1,p2,p3, etc)
				splitted[2] = new_page
				#splitted[3] is the same name as the subfolder
				subfolder = splitted[3]
				#you can now create the new name of the texture
				new_spritesheet = "_".join(splitted)
			#if you created a new name for the spritesheet/texture
			if new_spritesheet:
				#check if the subfolder is set and if it is not 0bas since these are in the base folder of the page
				if subfolder && subfolder != "0bas": new_spritesheet = subfolder + "/" + new_spritesheet
				#set the path of the sheet accordingly to what you set in your SpriteLayers
				var sprite_path = spritesheet_path+"/char_a_"+new_page+"/"+new_spritesheet+".png"
				if FileAccess.file_exists(sprite_path):
					var new_texture = load(sprite_path)
					#and it can be correctly loaded
					if new_texture != null:
						#set the texture of the layer to the new texture
						child_sprite.texture = new_texture
				#else:
					#child_sprite.texture = null					
	#set the current page to the one you got
	current_spritesheet_page = new_page

#get the full spritesheet name created, when you know
#layer (0bas, 1out, etc)
#type (humn, fstr, etc)
#version (v01, v02, v03)
func get_full_spritesheet_name(layer, type, version, forced_page = ""):
	#some stuff like the tools have a single page they are checked, you can force the page for the name
	var page = current_spritesheet_page
	if forced_page != "": page = forced_page
	return "char_a_"+page+"_"+layer+"_"+type+"_"+version

#get the name and the path
func get_full_spritesheet_name_and_path(layer, type, version, forced_page = ""):
	var page = current_spritesheet_page
	if forced_page != "" && forced_page != null: page = forced_page
	var path = "char_a_"+page+"/"
	#only add subfolder if it is not the 0bas layer
	if (layer != "0bas"):
		path += layer+"/"
	path += get_full_spritesheet_name(layer, type, version, page)
	return path
	
#check if the hair and hat are set, if both set and visible, hair should be invisible
func check_hat_and_hair():
	var hair = get_node("4har")
	var hat = get_node("5hat")
	if (hat.texture != null && hat.visible):
		hair.visible = false
	else:
		hair.visible = true

func emit_animation_state_finished(state_name:String):
	emit_signal("animation_state_finished", state_name)
