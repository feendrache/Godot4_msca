class_name MSCAPlayer
extends CharacterBody2D

@onready var animationPlayer = $SpriteLayers/AnimationPlayer
@onready var animationTree = $SpriteLayers/AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

const ACCELERATION = 10
const FRICTION = 10

@export var speed = 60
var facing_direction = Vector2.ZERO

func _ready():
	animationTree.set_animation_player(animationPlayer.get_path())
	animationTree.active = true

func travel_to_anim(animName:String, direction = null):
	if direction != null: facing_direction = direction
	
	animationTree.set("parameters/"+animName+"/blend_position", facing_direction)
	animationState.travel(animName)
	
