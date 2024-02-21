extends Node2D

var shader = preload("res://addons/msca/shader/ramp_shader_material.gdshader")

var color_swapper
var palettes

var farmer_base_path

func _init():
	color_swapper = MSCAPaletteSwaps.new()

func _ready():
	var player = get_node_or_null("Player")
	if player != null:
		$Camera2D.reparent(player)
		$Player/SpriteLayers.connect("animation_state_finished", Callable(self, "_on_animation_state_finished"))
		var body_layer = get_node_or_null("Player/SpriteLayers/01body")
		if body_layer != null:
			farmer_base_path = body_layer.texture.resource_path.replace("farmer_base_sheets/01body/fbas_01body_human_00.png","")
			load_palettes()

func load_palettes():
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
	for bp in palettes.values():
		var base_texture = load(bp["base_file"])
		bp["base"] = color_swapper.create_palette_from_image(base_texture.get_image())
		
		if bp["file"] != "":
			bp["palettes"] = []
			var _palettes = load(bp["file"])
			var palettes_image = _palettes.get_image()
			var palettes_count = palettes_image.get_height()/2
			for p in palettes_count:
				var start_y = p*2
				var palette_image = palettes_image.get_region(Rect2i(0,start_y,palettes_image.get_width(),2))
				var new_palette = color_swapper.create_palette_from_image(palette_image)
				if new_palette.size() > 0: bp["palettes"].append(new_palette)

func get_palette_shader(original_palette:Array = [], palette_to_set:Array = []) -> ShaderMaterial:
	if original_palette.size() > 0 && palette_to_set.size() > 0:
		var shader_material = ShaderMaterial.new()
		shader_material.shader = shader
		var p_count = 0
		
		for p in palette_to_set:
			shader_material.set_shader_parameter("original_"+str(p_count),original_palette[p_count])
			shader_material.set_shader_parameter("replace_"+str(p_count),p)
			p_count = p_count +1
		return shader_material
	return null

func _on_animation_state_finished(anim_name, _duration):
	#print(anim_name)
	match anim_name:
		"FishingCastLine": 
			$Player/SpriteLayers/fishing_up_down.visible = false
			$Player/SpriteLayers/fishing_right_left.visible = false
		"PlantSeeds":
			$"Player/SpriteLayers/32x32_anims".visible = false

func _on_walk_button_pressed():
	set_non_idle_anim("Walk", 60)

func _on_run_button_pressed():
	set_non_idle_anim("Run", 100)

func set_non_idle_anim(animName, speed = 60):
	var player = get_node_or_null("Player")
	if player == null: return
	player.speed = speed
	$Player/Movement.non_idle_anim = animName
	$Walk_Run_Controls/AnimLabel.text = animName

func get_shirt_tex():
	if farmer_base_path != "":
		var _path = farmer_base_path+"farmer_base_sheets/05shrt/fbas_05shrt_longshirt_00a.png"
		var _tex = load(_path)
		return _tex

func _on_shirt_button_pressed():
	var shirt_tex = get_shirt_tex()
	var shirt_layer = get_node_or_null("Player/SpriteLayers/05shrt")
	if shirt_layer != null: 
		shirt_layer.texture = shirt_tex
		shirt_layer.material = null

func _on_shirt_color_1_button_pressed():
	var shirt_tex = get_shirt_tex()
	var shirt_layer = get_node_or_null("Player/SpriteLayers/05shrt")
	if shirt_layer != null: 
		shirt_layer.texture = shirt_tex
		shirt_layer.material = get_palette_shader(palettes["3color"]["base"], palettes["3color"]["palettes"][5])

func _on_shirt_color_2_button_pressed():
	var shirt_tex = get_shirt_tex()
	var shirt_layer = get_node_or_null("Player/SpriteLayers/05shrt")
	if shirt_layer != null: 
		shirt_layer.texture = shirt_tex
		shirt_layer.material = get_palette_shader(palettes["3color"]["base"], palettes["3color"]["palettes"][30])

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

func _on_fishing_anim_button_pressed():
	var player = get_node_or_null("Player")
	player.travel_to_anim("FishingCastLine")
	match player.facing_direction:
		Vector2.DOWN, Vector2.UP: $Player/SpriteLayers/fishing_up_down.visible = true
		Vector2.LEFT, Vector2.RIGHT: $Player/SpriteLayers/fishing_right_left.visible = true
	
func _on_plant_seeds_button_pressed():
	var player = get_node_or_null("Player")
	player.travel_to_anim("PlantSeeds")
	$"Player/SpriteLayers/32x32_anims".visible = true

