@tool

## Node to use if you need a child node to read the screen only in one region, useful for stacked screen effects
class_name BackBufferCopy_Control
extends Control
var back_buffer : BackBufferCopy
var _cur_viewport : Viewport

func _enter_tree() -> void:
	if(not back_buffer):
		back_buffer = BackBufferCopy.new()
		back_buffer.copy_mode = BackBufferCopy.COPY_MODE_RECT
		back_buffer.show_behind_parent = true	
		add_child(back_buffer, false, Node.INTERNAL_MODE_BACK)
	_cur_viewport = get_viewport()	
	_cur_viewport.size_changed.connect(_notification.bind(NOTIFICATION_VIEWPORT_MODIFIED))	

const NOTIFICATION_VIEWPORT_MODIFIED = 555
func _notification(what: int) -> void:
	match(what):
		NOTIFICATION_DRAW || NOTIFICATION_MOVED_IN_PARENT || NOTIFICATION_VIEWPORT_MODIFIED:
			_reallign()

func _reallign():
	var inv = get_viewport().get_stretch_transform().inverse()
	var base_rect : Rect2 = get_rect()
	var my_trans = get_global_transform()
	base_rect.position = Vector2.ZERO
	base_rect = inv*my_trans * base_rect	
	back_buffer.rect = base_rect

func _exit_tree() -> void:
	if(_cur_viewport):
		if(_cur_viewport.size_changed.is_connected(_reallign)):
			_cur_viewport.size_changed.disconnect(_reallign)
