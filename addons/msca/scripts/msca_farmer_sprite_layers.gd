class_name MSCAFarmerSpriteLayers
extends Node2D

signal animation_state_finished(state_name,state_duration)
signal animation_state_started(state_name)
signal animation_set_hitbox(counter, track, timer_value, direction)
signal make_sound(state_name, sound_name)

var shader = preload("res://addons/msca/shader/simple_ramp_shader.gdshader")

func set_corresponding_layers_to_animframe(animframe:int, flipped:bool = false):
	#the Animation Tree must be disabled when you use this
	var corresponding_layers = [$"00undr",$"01body",$"02sock",$"03fot1",$"04lwr1",$"05shrt",$"06lwr2",$"07fot2",$"08lwr3",$"09hand",$"10outr",$"11neck",$"12face",$"13hair",$"14head",$"15over"]
	for l in corresponding_layers:
		if l != null:
			l.frame = animframe
			l.flip_h = flipped

func change_child_position(sprite_layer, pos):
	var spr_layer = self.get_node(sprite_layer)
	if (pos != null && spr_layer != null): self.move_child(spr_layer, pos)

func emit_animation_state_finished(state_name:String,wait_time:float):
	emit_signal("animation_state_finished", state_name, wait_time)

func emit_animation_state_started(state_name:String):
	emit_signal("animation_state_started", state_name)

func set_hitbox(counter, track, timer_value, direction):
	emit_signal("animation_set_hitbox", counter, track, timer_value, direction)

func emit_sound(state_name:String, sound_name:String):
	emit_signal("make_sound", state_name, sound_name)

#get the name and the path
func get_full_spritesheet_name_and_path(layer, type, version):
	var path = layer + "/" + get_full_spritesheet_name(layer, type, version)
	return path

func get_full_spritesheet_name(layer, type, version):
	#some stuff like the tools have a single page they are checked, you can force the page for the name
	return "fbas_"+layer+"_"+type+"_"+version

func set_shader(layer, original_ramp, new_ramp):
	original_ramp = MSCAPaletteSwaps.html_to_color_palette(original_ramp)
	new_ramp = MSCAPaletteSwaps.html_to_color_palette(new_ramp)
	var shader_material = null
	var layer_node = get_node_or_null(layer)
	if layer_node == null: return
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	var p_count = 0
	for p in new_ramp:
		shader_material.set_shader_parameter("original_"+str(p_count),original_ramp[p_count])
		shader_material.set_shader_parameter("replace_"+str(p_count),p)
		p_count = p_count +1
	layer_node.material = shader_material
