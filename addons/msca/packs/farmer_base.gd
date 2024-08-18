@tool
extends RefCounted

var animationPlayer = null
var animationTree = null
var spriteLayers = null
var blendNodes = []

var json_data = null
var bodyparts:Dictionary = {}
var additional_layers:Dictionary = {}

var root
var playerNode
var base_path
var create_sprite_layers:bool
var reference = "01body"

var spriteOffset = Vector2(0,-10)

func create_from_farmer_base(root_b, playerNode_b, base_path_b, create_sls:bool = true):
	root = root_b
	playerNode = playerNode_b
	base_path = base_path_b
	create_sprite_layers = create_sls
	
	loadJsonData()
	createPlayerStructure()
	createAnimations()
	createAnimationTree()

func createAnimationTree():
	var pos_vector = Vector2.ZERO
	var counter = 0
	var row_max = 4
	var row_counter = 0
	for blendNodeToAdd in blendNodes:
		pos_vector.x = counter * 200 + 150
		pos_vector.y = row_counter * 75 + 200
		#print(pos_vector)
		addBlendNode(blendNodeToAdd, pos_vector)
		counter = counter + 1
		if counter > row_max:
			counter = 0
			row_counter = row_counter + 1
	
	addTransitions()

func addTransitions():
	var first_transition = AnimationNodeStateMachineTransition.new()
	first_transition.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
	first_transition.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
	animationTree.get_tree_root().add_transition("Start", json_data.start_animation, first_transition)
	
	for animation in json_data.animations:
		var switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
		match animation.transition_switch_mode:
			"Immediate":
				switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
			"AtEnd":
				switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
			
		var from = animation.name
		var first = true
		for to in animation.transitions:
			var transition = AnimationNodeStateMachineTransition.new()	
			transition.switch_mode = switch_mode
			if first && animation.transition_auto_advance == true:
				transition.auto_advance = true
			if from != to:
				animationTree.get_tree_root().add_transition(from, to, transition)
			first = false

func addBlendNode(animType, pos):
	var blend_node = AnimationNodeBlendSpace2D.new()
	blend_node.set_max_space(Vector2(1, 1.1))
	blend_node.set_min_space(Vector2(-1, -1.1))
	blend_node.blend_mode = AnimationNodeBlendSpace2D.BLEND_MODE_DISCRETE
	
	if animationPlayer.has_animation(animType+"Down"):
		var anim_down = AnimationNodeAnimation.new()
		anim_down.set_animation(animType+"Down")
		blend_node.add_blend_point(anim_down, Vector2(0,1.1))
	if animationPlayer.has_animation(animType+"Up"):
		var anim_up = AnimationNodeAnimation.new()
		anim_up.set_animation(animType+"Up")
		blend_node.add_blend_point(anim_up, Vector2(0,-1.1))
	if animationPlayer.has_animation(animType+"Left"):
		var anim_left = AnimationNodeAnimation.new()
		anim_left.set_animation(animType+"Left")
		blend_node.add_blend_point(anim_left, Vector2(-1,0))
	if animationPlayer.has_animation(animType+"Right"):
		var anim_right = AnimationNodeAnimation.new()
		anim_right.set_animation(animType+"Right")
		blend_node.add_blend_point(anim_right, Vector2(1,0))
	
	if !animationTree.get_tree_root().has_node(animType):
		animationTree.get_tree_root().add_node(animType, blend_node, pos)

func createAnimations():
	var anim_lib = AnimationLibrary.new()
	animationPlayer.add_animation_library("", anim_lib)
	blendNodes = []
	for animation in json_data.animations:
		var animation_name = animation.name
		var anim_length = get_animation_length(animation)
		blendNodes.append(animation_name)
		
		for direction in animation.directions:
			var direction_data = animation.directions[direction]
			var direction_name = animation_name + direction
			var new_anim = Animation.new()
			new_anim.resource_name = direction_name
			new_anim.length = anim_length
			if animation.loop:
				match animation.loop_type:
					"linear":
						new_anim.loop_mode = Animation.LOOP_LINEAR
					"pingpong":
						new_anim.loop_mode = Animation.LOOP_PINGPONG
					_: 
						new_anim.loop_mode = Animation.LOOP_NONE
			
			new_anim.step = animation.step
			
			for track in bodyparts:
				createTracksInAnimation(track, direction_data, new_anim, animation, direction, bodyparts[track])
			for track in additional_layers:
				createTracksInAnimation(track, direction_data, new_anim, animation, direction, additional_layers[track])
			if "make_sound" in animation:
				addSoundTrack(new_anim, animation)
			addLastTracks(new_anim, animation, animation_name, anim_length)
			anim_lib.add_animation(direction_name, new_anim)

func addLastTracks(new_anim, animation, animation_name, anim_length):
	var first_frame = 0
	var last_frame = get_frame_time(animation, animation.timer.size())# -1)
	var signal_emitter_track_id = new_anim.add_track(Animation.TYPE_METHOD)
	new_anim.track_set_path(signal_emitter_track_id, ".")
	var start_method_params = {
		"method" : "emit_animation_state_started",
		"args": [animation_name]
	}
	new_anim.track_insert_key(signal_emitter_track_id, first_frame, start_method_params)
	#new_anim.value_track_set_update_mode(signal_emitter_track_id, Animation.UPDATE_DISCRETE)
	var method_params = {
		"method" : "emit_animation_state_finished",
		"args" : [animation_name, anim_length]
	}
	new_anim.track_insert_key(signal_emitter_track_id, last_frame, method_params)
	var total_tracks = new_anim.get_track_count()
	var remove: Array = []
	for i in total_tracks:
		if new_anim.track_get_key_count(i) == 0:
			new_anim.track_set_enabled(i, false)

func createTracksInAnimation(track, direction_data, new_anim, animation, direction, layer_data):
	var track_data = null
	if track in direction_data.tracks:
		track_data = direction_data.tracks[track]
	else: 
		track_data = layer_data
		
	if track_data != null:
		var track_id
		var counter
		var timer_value
		addFramesTrack(new_anim, track, track_data, direction_data, animation, layer_data)
		addFlipTracks(new_anim, track, track_data, direction_data, animation, layer_data)
		if "sorting" in track_data:
			addSortingTrack(new_anim, track, track_data, direction_data, animation, layer_data)
		addRotationTrack(new_anim, track, track_data, direction_data, animation, layer_data)
		addOffsetTrack(new_anim, track, track_data, direction_data, animation, direction, layer_data)
		addHVFramesTracks(new_anim, track, track_data, direction_data, animation, layer_data)
		addSpritesheetTrack(new_anim, track, track_data, direction_data, animation, layer_data)
		if "hitbox" in track_data && track_data["hitbox"]: addHitBoxTrack(new_anim, track, track_data, direction, animation, layer_data)

func addSpritesheetTrack(new_anim, track, track_data, direction_data, animation, layer_data):
	if "spritesheet" in track_data || "spritesheet" in layer_data:
		var spritesheet_track_id = new_anim.add_track(Animation.TYPE_VALUE)
		new_anim.track_set_path(spritesheet_track_id, track+":texture")
		new_anim.value_track_set_update_mode(spritesheet_track_id, Animation.UPDATE_DISCRETE)
		if "spritesheet" in track_data:
			new_anim.track_insert_key(spritesheet_track_id, 0, load(base_path+track_data.spritesheet))
		elif "spritesheet" in layer_data:
			new_anim.track_insert_key(spritesheet_track_id, 0, load(base_path+layer_data.spritesheet))

func addSoundTrack(new_anim, animation):
	if "frames" in animation["make_sound"] && "sound" in animation["make_sound"]:
		var sound_track_id = new_anim.add_track(Animation.TYPE_METHOD)
		new_anim.track_set_path(sound_track_id,".")
		var counter = 0
		for f in animation["make_sound"]["frames"]:
			var method_params = {
				"method" : "emit_sound",
				"args" : [animation["name"],animation["make_sound"]["sound"][counter]]
			}
			var key_time = get_frame_time(animation,f)
			new_anim.track_insert_key(sound_track_id, key_time, method_params)
			counter += 1

func addHVFramesTracks(new_anim, track, track_data, direction_data, animation, layer_data):
	var hframes_track_id = new_anim.add_track(Animation.TYPE_VALUE)
	var vframes_track_id = new_anim.add_track(Animation.TYPE_VALUE)
	new_anim.track_set_path(hframes_track_id, track+":hframes")
	new_anim.value_track_set_update_mode(hframes_track_id, Animation.UPDATE_DISCRETE)
	new_anim.track_set_path(vframes_track_id, track+":vframes")
	new_anim.value_track_set_update_mode(vframes_track_id, Animation.UPDATE_DISCRETE)
	if "size" in track_data:
		new_anim.track_insert_key(hframes_track_id, 0, track_data.size.h)
		new_anim.track_insert_key(vframes_track_id, 0, track_data.size.v)
	else:
		new_anim.track_insert_key(hframes_track_id, 0, layer_data.hframes)
		new_anim.track_insert_key(vframes_track_id, 0, layer_data.vframes)

func addOffsetTrack(new_anim, track, track_data, direction_data, animation, direction, layer_data):
	var timer_value = 0
	var counter = 0
	var has_offset = null
	if "offset" in track_data:
		has_offset = track_data.offset
	elif "init_offset" in layer_data:
		has_offset = []
		has_offset.append(layer_data.init_offset)
	elif "use_offset" in track_data && "offset" in direction_data.tracks[track_data.use_offset]:
		has_offset = direction_data.tracks[track_data.use_offset].offset
	if has_offset != null:
		timer_value = 0
		counter = 0
		var offset_track_id = new_anim.add_track(Animation.TYPE_VALUE)
		var offset_v = Vector2(0,0)
		new_anim.track_set_path(offset_track_id, track+":offset")
		new_anim.value_track_set_update_mode(offset_track_id, Animation.UPDATE_DISCRETE)
		for off in has_offset:
			off = off
			if "skip_offset" in track_data: offset_v = Vector2(off.x, off.y)
			else: offset_v = Vector2(off.x + spriteOffset.x, off.y + spriteOffset.y)
			new_anim.track_insert_key(offset_track_id, timer_value, offset_v)	
			timer_value = timer_value + animation.timer[counter]
			counter = counter + 1
	else:
		var offset = get_track_offset(track_data)
		var offset_track_id = new_anim.add_track(Animation.TYPE_VALUE)
		var offset_v = Vector2(0,0)
		new_anim.track_set_path(offset_track_id, track+":offset")
		new_anim.value_track_set_update_mode(offset_track_id, Animation.UPDATE_DISCRETE)
		match direction:
			"Down": offset_v.y = offset
			"Up": offset_v.y = -offset
			"Right": offset_v.x = offset
			"Left": offset_v.x = -offset
		offset_v = offset_v + spriteOffset
		if "init_offset" in layer_data:
			offset_v.x += track_data.init_offset.x
			offset_v.y += track_data.init_offset.y
		new_anim.track_insert_key(offset_track_id, 0, offset_v)

func addRotationTrack(new_anim, track, track_data, direction_data, animation, layer_data):
	var rotation = []
	if "rotation" in track_data:
		rotation = track_data.rotation
	else:
		for i in animation.timer.size():
			rotation.append(0)
	var timer_value = 0
	var counter = 0
	var rotation_track_id = new_anim.add_track(Animation.TYPE_VALUE)
	new_anim.track_set_path(rotation_track_id, track+":rotation")
	new_anim.value_track_set_update_mode(rotation_track_id, Animation.UPDATE_DISCRETE)
	for rot in rotation:
		new_anim.track_insert_key(rotation_track_id, timer_value, deg_to_rad(rot))
		timer_value = timer_value + animation.timer[counter]
		counter = counter + 1

func addSortingTrack(new_anim, track, track_data, direction_data, animation, layer_data):
	var sorting_track_id = new_anim.add_track(Animation.TYPE_METHOD)
	new_anim.track_set_path(sorting_track_id,".")
	#new_anim.value_track_set_update_mode(sorting_track_id, Animation.UPDATE_DISCRETE)
	var timer_value = 0
	var counter = 0
	for sort in track_data.sorting:
		var method_params = {
			"method" : "change_child_position",
			"args" : [track, sort]
		}
		new_anim.track_insert_key(sorting_track_id, timer_value, method_params)
		timer_value = timer_value + animation.timer[counter]
		counter = counter + 1

func addHitBoxTrack(new_anim, track, track_data, direction, animation, layer_data):
	var hitbox_track_id = new_anim.add_track(Animation.TYPE_METHOD)
	new_anim.track_set_path(hitbox_track_id,".")
	#new_anim.value_track_set_update_mode(sorting_track_id, Animation.UPDATE_DISCRETE)
	var timer_value = 0
	var counter = 0
	for frame in track_data.frames:
		var method_params = {
			"method" : "set_hitbox",
			"args" : [counter, track, timer_value, direction]
		}
		new_anim.track_insert_key(hitbox_track_id, timer_value, method_params)
		timer_value = timer_value + animation.timer[counter]
		counter = counter + 1

func addFlipTracks(new_anim, track, track_data, direction_data, animation, layer_data):
	var track_id = new_anim.add_track(Animation.TYPE_VALUE)
	new_anim.track_set_path(track_id, track+":flip_h")
	new_anim.value_track_set_update_mode(track_id, Animation.UPDATE_DISCRETE)
	var counter = 0
	var timer_value = 0
	var flips = get_false_array(animation.timer.size())
	if "flips" in track_data:
		flips = track_data.flips
	elif "use_flips" in track_data && "flips" in direction_data.tracks[track_data.use_flips]:
		flips = direction_data.tracks[track_data.use_flips].flips
	for flip in flips:
		new_anim.track_insert_key(track_id, timer_value, flip)
		timer_value = timer_value + animation.timer[counter]
		counter = counter + 1
	track_id = new_anim.add_track(Animation.TYPE_VALUE)
	new_anim.track_set_path(track_id, track+":flip_v")
	new_anim.value_track_set_update_mode(track_id, Animation.UPDATE_DISCRETE)
	counter = 0
	timer_value = 0
	var vflips = get_false_array(animation.timer.size())
	if "vflips" in track_data:
		vflips = track_data.vflips
	elif "use_vflips" in track_data && "vflips" in direction_data.tracks[track_data.use_vflips]:
		vflips = direction_data.tracks[track_data.use_vflips].vflips
	for vflip in vflips:
		new_anim.track_insert_key(track_id, timer_value, vflip)
		timer_value = timer_value + animation.timer[counter]
		counter = counter + 1

func addFramesTrack(new_anim, track, track_data, direction_data, animation, layer_data):
	var track_id = new_anim.add_track(Animation.TYPE_VALUE)
	new_anim.track_set_path(track_id, track+":frame")
	new_anim.value_track_set_update_mode(track_id, Animation.UPDATE_DISCRETE)
	var counter = 0
	var timer_value = 0
	var frames = []
	if "frames" in track_data:
		frames = track_data.frames
	elif "use_frames" in track_data:
		frames = direction_data.tracks[track_data.use_frames].frames
	else: 
		if "init_frame" in track_data:
			frames.append(track_data.init_frame)
		else:
			frames.append(-1)
	
	for frame in frames:
		if frame == -1:
			var max_frame = layer_data.hframes * layer_data.vframes -1
			new_anim.track_insert_key(track_id, timer_value, max_frame)
		else: 
			new_anim.track_insert_key(track_id, timer_value, frame)
		timer_value = timer_value + animation.timer[counter]
		counter = counter + 1

func createPlayerStructure():
	playerNode.name = "Player"
	playerNode.set_script(load("res://addons/msca/scripts/msca_player.gd"))
	root.add_child(playerNode)
	playerNode.set_owner(root)
	
	var moveNode = Node.new()
	moveNode.name = "Movement"
	moveNode.set_script(load("res://addons/msca/scripts/msca_movement.gd"))
	playerNode.add_child(moveNode)
	moveNode.set_owner(root)
	
	var spritesNode = MSCAFarmerSpriteLayers.new()
	spritesNode.name = "SpriteLayers"
	#spritesNode.set_position(Vector2(0,-9))
	playerNode.add_child(spritesNode)
	spritesNode.set_owner(root)
	
	var part_counter = 0
	for part in bodyparts:
		var new_layer = createSpriteLayer(part, bodyparts[part])
		spritesNode.add_child(new_layer)
		new_layer.set_owner(root)
		part_counter = part_counter + 1
	for part in additional_layers:
		var new_layer = createSpriteLayer(part, additional_layers[part])
		spritesNode.add_child(new_layer)
		new_layer.set_owner(root)
		part_counter = part_counter + 1
	
	var animationPlayerNode = AnimationPlayer.new()
	animationPlayerNode.name = "AnimationPlayer"
	spritesNode.add_child(animationPlayerNode)
	animationPlayerNode.set_owner(root)
	animationPlayer = animationPlayerNode
	
	var animationTreeNode = AnimationTree.new()
	animationTreeNode.name = "AnimationTree"
	spritesNode.add_child(animationTreeNode)
	animationTreeNode.set_owner(root)
	animationTree = animationTreeNode
	animationTree.set_animation_player(animationPlayer.get_path())
	var animationRootNode = AnimationNodeStateMachine.new()
	animationTree.set_tree_root(animationRootNode)	

	var collisionNode = CollisionShape2D.new()
	var collisionShape = CapsuleShape2D.new()
	collisionNode.name = "CollisionShape2D"
	collisionNode.set_rotation(deg_to_rad(-90))
	collisionShape.set_height(10)
	collisionShape.set_radius(2)
	collisionNode.set_shape(collisionShape)
	
	playerNode.add_child(collisionNode)
	collisionNode.set_owner(root)

func createSpriteLayer(part, part_info):
	var spriteNode = Sprite2D.new()
	spriteNode.name = part
	spriteNode.hframes = part_info.hframes
	spriteNode.vframes = part_info.vframes
	if "visible" in part_info: 
		spriteNode.visible = part_info.visible
	if "init_frame" in part_info:
		spriteNode.frame = part_info.init_frame
	if "init_opacity" in part_info:
		spriteNode.self_modulate.a = part_info.init_opacity
	if "init_offset" in part_info:
		spriteNode.offset.x = part_info.init_offset.x
		spriteNode.offset.y = part_info.init_offset.y
	else:
		spriteNode.offset = spriteOffset
	if "base_spritesheet" in part_info && base_path != "":
		var spritesheet = load(base_path+part_info.base_spritesheet)
		spriteNode.texture = spritesheet
	
	return spriteNode

func get_animation_length(anim_data):
	return get_frame_time(anim_data, anim_data.timer.size())

func get_frame_time(anim_data, frame_nr):
	var length = anim_data.step
	
	if anim_data.timer.size() > 1:
		length = 0
		var counter = 0
		for timer in anim_data.timer:
			if counter < frame_nr: length = length + timer 
			counter += 1
	
	return length

func get_track_offset(layer_info):
	var offset = 0
	
	if "base_offset" in layer_info:
		offset = layer_info.base_offset
	
	return offset

func get_false_array(size):
	var false_array = []
	for i in size:
		false_array.append(false)
	return false_array

func loadJsonData():
	var file = FileAccess.open("res://addons/msca/jsons/farmer_base_animations.json", FileAccess.READ)
	var file_content = file.get_as_text()
	
	var test_json_conv = JSON.new()
	var error = test_json_conv.parse(file_content)
	if error == OK:
		json_data = test_json_conv.get_data()
		if create_sprite_layers:
			bodyparts = json_data.bodyparts
		else:
			bodyparts = json_data.nonlayer_bodyparts
		additional_layers = json_data.additional_layers
	else:
		json_data = null
