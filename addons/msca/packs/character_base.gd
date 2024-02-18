@tool
extends RefCounted

const TLA_BASE_POS = 7
const TLB_BASE_POS = 8

var animationPlayer = null
var animationTree = null
var spriteLayers = null
var cb_bodyparts = ["0bot","0bas","1out","2clo","3fac","4har","5hat","6tla","7tlb"]
var blendNodes = []

var root
var playerNode

func create_from_character_base(root_b, playerNode_b, base_path):
	root = root_b
	playerNode = playerNode_b
	
	createPlayerStructure()
	createAnimations()
	fillAnimationTree()
	animationTree.set_active(true)
	#animationTree.get_tree_root().set_start_node("Idle")

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
	
	var spritesNode = MSCASpriteLayers.new()
	spritesNode.name = "SpriteLayers"
	spritesNode.set_position(Vector2(0,-9))
	playerNode.add_child(spritesNode)
	spritesNode.set_owner(root)	
	
	var part_counter = 0
	for part in cb_bodyparts:
		var spriteNode = Sprite2D.new()
		spriteNode.name = part
		spriteNode.hframes = 8
		spriteNode.vframes = 8
		spriteNode.offset = Vector2(0,-8)
		spritesNode.add_child(spriteNode)
		spriteNode.set_owner(root)
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
	collisionNode.set_rotation(-90)
	collisionShape.set_height(8)
	collisionShape.set_radius(3)
	collisionNode.set_shape(collisionShape)
	
	playerNode.add_child(collisionNode)
	collisionNode.set_owner(root)

func createAnimations():
	var file = FileAccess.open("res://addons/msca/jsons/msca_base_animations.json", FileAccess.READ)
	var file_content = file.get_as_text()
	
	var test_json_conv = JSON.new()
	var error = test_json_conv.parse(file_content)	
	if error == OK:
		var json_data = test_json_conv.get_data()
		
		var anim_lib = AnimationLibrary.new()
		for animation in json_data.animations:
			var animation_name = animation.name
			var animation_page = animation.page
			blendNodes.append(animation_name)
			
			for direction in animation.directions:
				var direction_name = animation_name + direction
				var new_anim = Animation.new()
				new_anim.resource_name = direction_name
				new_anim.length = animation.length
				if animation.loop:
					new_anim.loop_mode = Animation.LOOP_LINEAR
				
				new_anim.step = animation.step
				var tla_frames = false
				var tlb_frames = false
				for bodypart in cb_bodyparts:
					var track_id = new_anim.add_track(Animation.TYPE_VALUE)
					new_anim.track_set_path(track_id, bodypart+":frame")
					new_anim.value_track_set_update_mode(track_id,Animation.UPDATE_DISCRETE)
					var counter = 0
					for frame in animation.directions[direction].frames:
						new_anim.track_insert_key(track_id, animation.timer[counter], frame)
						counter = counter + 1
						
					
					if (animation.directions[direction].has("tla") && bodypart == "6tla"):
						tla_frames = animation.directions[direction].tla
					if (animation.directions[direction].has("tlb") && bodypart == "7tlb"):
						tlb_frames = animation.directions[direction].tlb
				#set tla/tlb visibility
				var tla_track_id = new_anim.add_track(Animation.TYPE_VALUE)
				new_anim.track_set_path(tla_track_id, "6tla:visible")
				new_anim.value_track_set_update_mode(tla_track_id,Animation.UPDATE_DISCRETE)
				new_anim.track_insert_key(tla_track_id, 0, animation.tla_visible)
				var tlb_track_id = new_anim.add_track(Animation.TYPE_VALUE)
				new_anim.track_set_path(tlb_track_id, "7tlb:visible")
				new_anim.value_track_set_update_mode(tlb_track_id,Animation.UPDATE_DISCRETE)
				new_anim.track_insert_key(tlb_track_id, 0, animation.tlb_visible)
				#place spreadsheet nr
				var spreadsheet_nr_track_id = new_anim.add_track(Animation.TYPE_VALUE)
				new_anim.track_set_path(spreadsheet_nr_track_id, ".:spritesheet_page")
				new_anim.value_track_set_update_mode(spreadsheet_nr_track_id,Animation.UPDATE_DISCRETE)
				new_anim.track_insert_key(spreadsheet_nr_track_id, 0, animation.page)				
				
				#create order changes
				if tla_frames:
					var frame_counter = 0
					var bodypart_order_track_id = new_anim.add_track(Animation.TYPE_METHOD)
					new_anim.track_set_path(bodypart_order_track_id, ".")
					#new_anim.value_track_set_update_mode(bodypart_order_track_id,Animation.UPDATE_DISCRETE)

					for tla_frame in tla_frames:
						var tlb_frame = TLB_BASE_POS
						if tlb_frames:
							tlb_frame = tlb_frames[frame_counter]
						var method_params = {
							"method" : "change_child_position",
							"args" : [tla_frame, tlb_frame]
						}
						new_anim.track_insert_key(bodypart_order_track_id, animation.timer[frame_counter], method_params)
						frame_counter = frame_counter + 1
				
				#add signal emitter
				var last_frame = animation.timer[animation.timer.size() -1]
				var signal_emitter_track_id = new_anim.add_track(Animation.TYPE_METHOD)
				new_anim.track_set_path(signal_emitter_track_id, ".")
				var method_params = {
					"method" : "emit_animation_state_finished",
					"args" : [animation_name]
				}
				new_anim.track_insert_key(signal_emitter_track_id, last_frame, method_params)
				anim_lib.add_animation(direction_name, new_anim)
				
		animationPlayer.add_animation_library("", anim_lib)

func fillAnimationTree():
	var pos_vector = Vector2(-100,100)
	var add_vector = Vector2(150,0)
	for blendNodeToAdd in blendNodes:
		pos_vector += add_vector
		if pos_vector.x > 650:
			pos_vector.x = 50
			pos_vector.y += 100
		addBlendNode(blendNodeToAdd, pos_vector)
	
	addTransitions()

func addBlendNode(animType, pos):
	var blend_node = AnimationNodeBlendSpace2D.new()
	blend_node.set_max_space(Vector2(1, 1.1))
	blend_node.set_min_space(Vector2(-1, -1.1))
	blend_node.blend_mode = AnimationNodeBlendSpace2D.BLEND_MODE_DISCRETE
	
	var anim_down = AnimationNodeAnimation.new()
	anim_down.set_animation(animType+"Down")
	blend_node.add_blend_point(anim_down, Vector2(0,1.1))
	var anim_up = AnimationNodeAnimation.new()
	anim_up.set_animation(animType+"Up")
	blend_node.add_blend_point(anim_up, Vector2(0,-1.1))
	var anim_left = AnimationNodeAnimation.new()
	anim_left.set_animation(animType+"Left")
	blend_node.add_blend_point(anim_left, Vector2(-1,0))
	var anim_right = AnimationNodeAnimation.new()
	anim_right.set_animation(animType+"Right")
	blend_node.add_blend_point(anim_right, Vector2(1,0))
	
	animationTree.get_tree_root().add_node(animType, blend_node, pos)

func addTransitions():
	var file = FileAccess.open("res://addons/msca/msca_base_animations.json", FileAccess.READ)
	var file_content = file.get_as_text()
	
	var test_json_conv = JSON.new()
	var error = test_json_conv.parse(file_content)
	if error == OK:
		var json_data = test_json_conv.get_data()
		for animation in json_data.animations:
			var switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
			match animation.transition_switch_mode:
				"Immediate":
					switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
				"AtEnd":
					switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
				
			var from = animation.name
			for to in animation.transitions:
				var transition = AnimationNodeStateMachineTransition.new()	
				transition.switch_mode = switch_mode
				animationTree.get_tree_root().add_transition(from, to, transition)
