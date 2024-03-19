extends Node2D

###########################
### Test Scene for the MSCA
# This scenes code is depending on the Base Path of the Farmer SpriteSystem being set in the MSCA and with that
# that all the Sprite Textures that could be set with creating like the body and the 32x32 anims are set as textures
# in the respective layers.
# It also depends on the FarmerSpriteSystem Folder structure as it was created by Seliel so the script can calculate
# the paths of the other Textures out of the body texture.


# very simple shader, provided by this plugin
var shader = preload("res://addons/msca/shader/ramp_shader_material.gdshader")

# store the palettes you want to use
var palettes

# get the base path of the sprites of the Farmer Sprite System 
var farmer_base_path

func _ready():
	# check if there is a player node at all (for this test scene to be able to run it's stuff it needs to be named "Player" just as the msca names the node
	var player = get_node_or_null("Player")
	# if there is a player node
	if player != null:
		# reparent the camera, so it follows the player
		$Camera2D.reparent(player)
		# connect the "animation state finished" event from the sprite layers to be able to react to an ending animation
		$Player/SpriteLayers.connect("animation_state_finished", Callable(self, "_on_animation_state_finished"))
		# get the body layer of the player
		var body_layer = get_node_or_null("Player/SpriteLayers/01body")
		if body_layer != null:
			# it is needed to get the base path of the sprite system out of it
			farmer_base_path = body_layer.texture.resource_path.replace("farmer_base_sheets/01body/fbas_01body_human_00.png","")
			# after getting the base path we can load the palettes
			load_palettes()

# in my game i load all the palettes like this (next to the 3 and 4 ramps the hairs and body ramps too)
func load_palettes():
	# the palette informations contain the paths of the base ramps and the full set of ramps offered.
	palettes = {
			"3color": {
				"base_file": farmer_base_path+"_supporting files/palettes/base ramps/3-color base ramp (00a).png",
				"file": farmer_base_path+"_supporting files/palettes/mana seed 3-color ramps.png",
				"base": null,
				"palettes": null
			},
			"4color": {
				"base_file": farmer_base_path+"_supporting files/palettes/base ramps/4-color base ramp (00b).png",
				"file": farmer_base_path+"_supporting files/palettes/mana seed 4-color ramps.png",
				"base": null,
				"palettes": null
			},
		}
	# for each of the palette types defined above
	for bp in palettes.values():
		# the colors of the base textures are extracted
		var base_texture = load(bp["base_file"])
		# the color swapper in the msca has a function that can get the colors out of an image
		bp["base"] = MSCAPaletteSwaps.create_palette_from_image(base_texture.get_image())
		if bp["file"] != "":
			# for the other palettes
			bp["palettes"] = []
			var _palettes = load(bp["file"])
			# the whole image is loaded
			var palettes_image = _palettes.get_image()
			# then the amount of palettes in this image is calculated (each palette is 2px high)
			var palettes_count = palettes_image.get_height()/2
			# for each of this palettes
			for p in palettes_count:
				var start_y = p*2
				# a palette image is cut out
				var palette_image = palettes_image.get_region(Rect2i(0,start_y,palettes_image.get_width(),2))
				# and the palette is extracted with the swapper
				var new_palette = MSCAPaletteSwaps.create_palette_from_image(palette_image)
				# if there are colors in the palette (to not add the empty rows) it is added to the array of possible palettes
				if new_palette.size() > 0: bp["palettes"].append(new_palette)
				# even if i store these palettes here in this array, when i save the informations for the playe or items,
				# the actual color values are saved not the position in the palette array, so even if the base image changes
				# the colors of already existend objects will stay the same

# the coloring of the different layers is done with a shade wich is also included in the msca
# this function creates the palette shader for a layer out of the original base palette and the new palette that the layer should have
func get_palette_shader(original_palette:Array = [], palette_to_set:Array = []) -> ShaderMaterial:
	# only create a shader material when the palette-sizes are > 0
	if original_palette.size() > 0 && palette_to_set.size() > 0 && original_palette.size() == palette_to_set.size():
		# create a new shader material
		var shader_material = ShaderMaterial.new()
		# set the shader to the loaded shader
		shader_material.shader = shader
		var p_count = 0
		# for each color in the palette to set, set two shader parameters: the original color and the replacement color
		for p in palette_to_set:
			shader_material.set_shader_parameter("original_"+str(p_count),original_palette[p_count])
			shader_material.set_shader_parameter("replace_"+str(p_count),p)
			p_count = p_count +1
		return shader_material
	return null

# react to the finishing of an animation, since the signal provided by godot with the anim player is not really working with
# the anim tree i included a "animation finished" signal with all the animations
func _on_animation_state_finished(anim_name, _duration):
	# with the tool using animations you need to deactivate visibility after the animation is finished
	match anim_name:
		"FishingCastLine": 
			$Player/SpriteLayers/fishing_up_down.visible = false
			$Player/SpriteLayers/fishing_right_left.visible = false
			# don't forget to reenable movement
			$Player/Movement.enabled = true
		"PlantSeeds":
			$"Player/SpriteLayers/32x32_anims".visible = false
			# don't forget to reenable movement
			$Player/Movement.enabled = true

# change the movement type to walk
func _on_walk_button_pressed():
	set_movement_anim("Walk", 60)

# change the movement type to run
func _on_run_button_pressed():
	set_movement_anim("Run", 100)

# this changes the movement type (run or walk)
func set_movement_anim(animName, speed = 60):
	var player = get_node_or_null("Player")
	if player == null: return
	player.speed = speed
	$Player/Movement.movement_anim = animName
	$Walk_Run_Controls/AnimLabel.text = animName

# get the texture for the shirt, that the button will give you
func get_shirt_tex():
	if farmer_base_path != "":
		var _path = farmer_base_path+"farmer_base_sheets/05shrt/fbas_05shrt_longshirt_00a.png"
		var _tex = load(_path)
		return _tex

# put on an uncolored shirt
func _on_shirt_button_pressed():
	var shirt_tex = get_shirt_tex()
	var shirt_layer = get_node_or_null("Player/SpriteLayers/05shrt")
	if shirt_layer != null: 
		shirt_layer.texture = shirt_tex
		shirt_layer.material = null

# color the shirt with one color
func _on_shirt_color_1_button_pressed():
	var shirt_tex = get_shirt_tex()
	var shirt_layer = get_node_or_null("Player/SpriteLayers/05shrt")
	if shirt_layer != null: 
		shirt_layer.texture = shirt_tex
		shirt_layer.material = get_palette_shader(palettes["3color"]["base"], palettes["3color"]["palettes"][5])

# color the shirt with another color
func _on_shirt_color_2_button_pressed():
	var shirt_tex = get_shirt_tex()
	var shirt_layer = get_node_or_null("Player/SpriteLayers/05shrt")
	if shirt_layer != null: 
		shirt_layer.texture = shirt_tex
		shirt_layer.material = get_palette_shader(palettes["3color"]["base"], palettes["3color"]["palettes"][30])

# the following funcs set the trowsers
func get_bottom_tex():
	if farmer_base_path != "":
		var _path = farmer_base_path+"farmer_base_sheets/04lwr1/fbas_04lwr1_longpants_00a.png"
		var _tex = load(_path)
		return _tex

func _on_trousers_button_pressed():
	var bottom_tex = get_bottom_tex()
	var bottom_layer = get_node_or_null("Player/SpriteLayers/04lwr1")
	if bottom_layer != null:
		bottom_layer.texture = bottom_tex
		bottom_layer.material = null

func _on_trousers_color_1_button_pressed():
	var bottom_tex = get_bottom_tex()
	var bottom_layer = get_node_or_null("Player/SpriteLayers/04lwr1")
	if bottom_layer != null:
		bottom_layer.texture = bottom_tex
		bottom_layer.material = get_palette_shader(palettes["3color"]["base"], palettes["3color"]["palettes"][2])

func _on_trousers_color_2_button_pressed():
	var bottom_tex = get_bottom_tex()
	var bottom_layer = get_node_or_null("Player/SpriteLayers/04lwr1")
	if bottom_layer != null:
		bottom_layer.texture = bottom_tex
		bottom_layer.material = get_palette_shader(palettes["3color"]["base"], palettes["3color"]["palettes"][32])

# when you start the fishing cast line animation you need to trigger the anim and set visibility the the right layer
func _on_fishing_anim_button_pressed():
	# movement needs to be disabled during playing the anim
	$Player/Movement.enabled = false
	var player = get_node_or_null("Player")
	player.travel_to_anim("FishingCastLine")
	# the player-script stores it's facing direction
	match player.facing_direction:
		Vector2.DOWN, Vector2.UP: $Player/SpriteLayers/fishing_up_down.visible = true
		Vector2.LEFT, Vector2.RIGHT: $Player/SpriteLayers/fishing_right_left.visible = true

# when you trigger the plant seeds anim, you need to set the 32x32anims layer visible so you can see the seeds falling
func _on_plant_seeds_button_pressed():
	# movement needs to be disabled during playing the anim
	$Player/Movement.enabled = false
	var player = get_node_or_null("Player")
	player.travel_to_anim("PlantSeeds")
	$"Player/SpriteLayers/32x32_anims".visible = true
