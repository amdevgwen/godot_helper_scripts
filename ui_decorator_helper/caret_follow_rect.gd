## Use this node to track behind control elements in certain groups
##
## This works by connecting to those controls "on focus_entered" callback to set the target references
## It's helpful to have the panel decorator be a panel with a high enough "expand margins" that it shows around the target
## Notes:
## uses a metadata tag if it should use the parent's size and position instead of the focused control, useful to reduce jitter on animated buttons.
class_name CaretFollowRect
extends Panel
@export var move_speed : float = 32.0
@export var debug_ref : Array[Control]
@export var scale_speed : float = 126.0

var target_position : Vector2
var target_size : Vector2
var target_control : Control
@export var follow_group_target : String = "caret_focus_target"

const use_parent_metadata_flag : String = "use_parent_control"

func _enter_tree() -> void:
	target_position = global_position
	target_size = size
	call_deferred("get_group")

func get_group():
	debug_ref.assign(get_tree().get_nodes_in_group(follow_group_target))
	for y in debug_ref:
		register_control(y)

func _process(delta):
	if(target_control):
		target_position = target_control.global_position
		target_size = target_control.size
	
	## frame independent interpolation
	var weight = 1 - exp(-move_speed * delta)
	global_position = global_position.lerp(target_position, weight)
	weight = 1.0-exp(-scale_speed * delta)
	size = size.lerp(target_size, weight)	

func register_control(v:Control):
	if(v):
		var _v = v
		if (v.get_meta(use_parent_metadata_flag, false)):
			_v = v.get_parent()
		v.focus_entered.connect(notify_follow.bind(_v))
		v.focus_exited.connect(notify_disappear.bind(_v))

## sets the target controls
func notify_follow(v : Control):
	target_control = v
	target_position = v.global_position
	target_size = v.size

## clears the target
func notify_disappear(_v : Control):
	if(target_control == _v):
		target_control = null