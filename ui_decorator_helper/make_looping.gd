## Helper node to add as a child of a box container to make the controls loop from end to front
## Notes: \n
## This should probably be an internal script but I don't want to code a whole UI for that. 

class_name MakeGroupLooping
extends Node

var queued_order : bool
var target_control : Control

## initial setups and connections
func _ready():
	var y = get_parent()	
	if not (y is BoxContainer || y is SlideBoxContainer):
		#FancyPrintHelper.print_gwen_warning(self,"Tried to add a MAKELOOPING menu to a non-container, oops")
		queue_free()
	
	var x = y as Control
	target_control = x
	x.child_order_changed.connect(_queue_looping)
	queued_order = true

func _process(delta):
	if(queued_order):
		queued_order = false		
		_make_looping(target_control)

func _queue_looping():
	queued_order = true

const _FOCUS_TOP : StringName = "focus_neighbor_top"
const _FOCUS_BOT : StringName = "focus_neighbor_bottom"
const _FOCUS_LEFT : StringName = "focus_neighbor_left"
const _FOCUS_RIGHT : StringName = "focus_neighbor_right"
func _make_looping(x:Control):
	var first_control : Control = null
	var last_control : Control = null
	var prev_string : StringName = _FOCUS_LEFT
	var next_string : StringName = _FOCUS_RIGHT

	for y in x.get_children():		
		if(y is not Control) || not y.visible:
			continue
		
		## checks children just in case
		if (y as Control).focus_mode == Control.FOCUS_NONE :
			y = y.get_child(0)
			if(y is not Control || y.focus_mode == Control.FOCUS_NONE):
				continue
				
		if(x.vertical):
			prev_string = _FOCUS_TOP	
			next_string = _FOCUS_BOT
			pass

		if(first_control == null):
			first_control = y	
		if(is_instance_valid(last_control)):
			last_control[next_string] = last_control.get_path_to(y)
		
		if(last_control):
			y[prev_string] = y.get_path_to(last_control)
		last_control = y
	
	if(last_control != null && first_control!= null):
		last_control[next_string] = last_control.get_path_to(first_control)
		first_control[prev_string] = first_control.get_path_to(last_control)