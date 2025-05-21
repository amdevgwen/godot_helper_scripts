## A parent node of a boxcontainer or similar node, keeps the container's currently selected node in bounds if applicable
class_name ContainerRefocuser
extends Control
@export var move_speed : float = 32.0
@export var tween_speed : float

var target_offset : Vector2
var container_control : Container
var reference_position : Vector2
func _ready():
	reference_position = position
	var v = get_child(0)
	if(v) && v is Container:
		print("child is a valid instance")
	else:
		return
	container_control = v
	
	container_control.child_entered_tree.connect(add_focus_control)
	set_initial(container_control)

func add_focus_control(y : Node):
	if(y is not Control):
		return	
	var ref_control : Control = y

	## checks children once again.
	if (y as Control).focus_mode == Control.FOCUS_NONE :
		y = y.get_child(0)
		if(y is not Control || y.focus_mode == Control.FOCUS_NONE):
			return	
	
	var z = y as Control
	if(z.focus_entered):
		var call_able = refocus_group.bind(ref_control)
		if(!z.focus_entered.is_connected(call_able)):
			z.focus_entered.connect(call_able)

func set_initial(x : Control):
	for y in x.get_children():
		add_focus_control(y)

## add support for horizontal layout groups
func refocus_group(child : Control):
	var size_ref = size
	var button_anchor = child.position
	var o = (button_anchor + target_offset)
	var y = (button_anchor + child.size + target_offset)
	#print(v.position)
	var skew := Vector2.DOWN
	if(container_control is SlideBoxContainer):
		skew = container_control.skew
	else:
		if not (container_control as BoxContainer).vertical:
			skew = Vector2.LEFT
			pass
	
	if(o.y < 0 || y.y < 0):
		target_offset = -button_anchor
	elif(o.y > size_ref.y || y.y > size_ref.y):
		button_anchor += child.size		
		target_offset = ((button_anchor.y * -skew) - (size.y * -skew))
		#target_offset =  -((size_ref.y * -skew)+(button_anchor))# - (size_ref.y-child.size.y) * skew
	else:
		return	
	pass

func _process(delta):
	var weight = 1 - exp(-move_speed * delta)
	position = position.lerp(reference_position+target_offset, weight)
	pass
