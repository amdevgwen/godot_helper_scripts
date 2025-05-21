## Messy tool container that organizes child elements similar to a box container aong a skewed axis,
@tool
class_name SlideBoxContainer
extends Container
static var vertical = true
@export var separation : float :
	get:
		return separation
	set(v):
		if(v != separation):
			separation = v
			queue_sort()

@export var skew : Vector2 : 
	get: 
		return skew 
	set(v):
		if(skew != v):
			skew = v
			queue_sort()

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		var base_position = Vector2.ZERO
		var end_size : Vector2 = Vector2.ZERO
		for c in get_children():
			if(not is_instance_valid(c)):
				return
			if(c is not Control || c.visible  == false):
				continue
			
			var x : Control = c
			x.size = x.get_minimum_size()
			x.position = base_position	
			x.pivot_offset = x.size/2.0		
			end_size = abs(x.position) + abs(x.size)
			base_position += x.size.y * skew			
			base_position += separation * skew
		
		if(end_size != size):
			set_size(end_size)
			queue_sort()
