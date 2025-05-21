@tool 
## This class is an animated button that bounces around w/o effecting UI ordering or container refocusing 
class_name TweenerButton
extends BaseButton

var button_rid : RID
#@export var font : Font

@export var punch_transition : Tween.TransitionType = Tween.TRANS_SPRING
@export var focus_punch : bool = false

var _button_label : String = "Tweener Button"
@export var button_label : String = "Tweener Button":
	get:
		return _button_label
	set(v):
		if(v != _button_label):
			_button_label = v
			minimum_size_changed.emit()
			queue_redraw()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			_get_theme_info()
			queue_redraw()
		NOTIFICATION_FOCUS_EXIT:
			queue_redraw()

var _timer : float = 0.0
var _ref_pos : Rect2

func _ready():
	_timer = 0.0
	_ref_pos = Rect2()
	if(focus_punch):
		focus_entered.connect(punch_control.bind(Vector2(0.4,0)))
	call_deferred("_notification", NOTIFICATION_THEME_CHANGED)
	if(visible):
		call_deferred("visibility_entrance_control")

func _process(delta):
	_timer += delta
	if(punch_tween && punch_tween.is_running()) || (entrance_tween &&entrance_tween.is_running()):
		queue_redraw()


func _draw():
	if not (button_rid):
		button_rid = get_canvas_item()
		if not (button_rid):
			return

	_ref_pos = get_rect()
	_ref_pos.position = punch_vector+entrance_vector
	
	draw_box()
	draw_label()

	if(has_focus()):
		_stylebox_focus.draw(button_rid, _ref_pos)

func draw_box():
	var current_draw_box : StyleBox
	## tbh could just set these to an array like an actual person
	## you could parse the draw mode as an int and have _styleboxes[get_draw_mode] grab the rect, didn't see is in the docs until recent.y
	match get_draw_mode():
		DRAW_HOVER:
			current_draw_box = _stylebox_hover
		DRAW_PRESSED:
			current_draw_box = _stylebox_pressed
			pass
		DRAW_HOVER_PRESSED:
			current_draw_box = _stylebox_hover_pressed
			pass
		DRAW_DISABLED:
			current_draw_box = _stylebox_disabled
			pass
		DRAW_NORMAL:
			current_draw_box = _stylebox_normal	
			pass
		pass
		
	if(current_draw_box):
		current_draw_box.draw(button_rid, _ref_pos)

func draw_label():
	if _button_label:
		if not (_font):
			return
		var font_size : Vector2 = _font.get_string_size(_button_label, 0, -1, _font_size)
		var font_pos = entrance_vector+ punch_vector+ ((_ref_pos.size)/2.0)

		var _label_color : Color = _font_color
		match get_draw_mode():
			DRAW_HOVER:
				_label_color = _font_hover
			DRAW_PRESSED:
				_label_color = _font_pressed
				pass
			DRAW_HOVER_PRESSED:
				_label_color = _font_hover_pressed
				pass
			DRAW_DISABLED:
				_label_color = _font_disabled_color
				pass
				
		font_pos.y += font_size.y * 0.25
		font_pos.x -= font_size.x/2.0
		_font.draw_string(button_rid,font_pos, _button_label, HORIZONTAL_ALIGNMENT_CENTER, -1, _font_size,_label_color*modulate)


var punch_tween : Tween
var punch_vector : Vector2 = Vector2.ZERO
func punch_control(dir : Vector2 = Vector2(0.3,0), punch_duration : float = 0.2):
	if(punch_tween):
		punch_tween.kill()
	punch_tween = create_tween().set_trans(punch_transition)
	punch_vector = size * dir
	punch_tween.tween_property(self, "punch_vector", Vector2.ZERO, punch_duration).set_ease(Tween.EASE_OUT)

var entrance_tween : Tween
@export var entrance_tween_type : Tween.TransitionType
@export var entrance_length : float = 0.24
var entrance_vector : Vector2 = Vector2.ZERO

func visibility_entrance_control():
	if(Engine.is_editor_hint()):
		return	
	if(entrance_tween):
		entrance_tween.kill()
	entrance_vector = Vector2(-size.x,0)	
	
	await get_tree().process_frame
	entrance_tween = create_tween().set_trans(entrance_tween_type).set_ease(Tween.EASE_OUT)
	entrance_tween.tween_interval(get_index() * entrance_length * 0.1)	
	entrance_tween.tween_property(self, "entrance_vector", Vector2.ZERO, entrance_length)

	if(true):
		modulate.a = 0.12	
		entrance_tween.set_parallel()
		entrance_tween.tween_property(self, "modulate:a", 1.0, entrance_length*2).set_trans(Tween.TRANS_CIRC)
	pass

#region matching stylebox functionality


## COLORS
var _font : Font
var _font_size : int

var _font_color : Color
var _font_disabled_color: Color
var _font_hover : Color
var _font_focus_color : Color
var _font_hover_pressed : Color
var _font_pressed : Color

var _stylebox_disabled : StyleBox
var _stylebox_hover_pressed : StyleBox
var _stylebox_hover : StyleBox
var _stylebox_pressed : StyleBox
var _stylebox_normal : StyleBox
var _stylebox_focus : StyleBox

## because of the way get_theme_* works you're going to want to pass the **actual** class name here, get_class() returns basebutton, and breaks some things
const _class_id :String= "TweenerButton"
func _get_theme_info():
	var themeID : String = _class_id
	_font = get_theme_font(&"font", themeID)
	_font_size = get_theme_font_size(&"font_size", themeID)
	_font_color = get_theme_color(&"font_color", themeID)
	_font_focus_color = get_theme_color(&"font_focus_color",themeID)
	_font_disabled_color = get_theme_color(&"font_disabled_color", themeID)
	_font_hover = get_theme_color(&"font_hover_color", themeID)
	_font_hover_pressed = get_theme_color(&"font_hover_pressed_color", themeID)
	_font_pressed = get_theme_color(&"font_pressed_color", themeID)
	_stylebox_normal = get_theme_stylebox(&"normal", themeID)
	_stylebox_pressed = get_theme_stylebox(&"pressed", themeID)
	_stylebox_hover = get_theme_stylebox(&"hover", themeID)
	_stylebox_hover_pressed = get_theme_stylebox(&"hover_pressed", themeID)
	_stylebox_disabled = get_theme_stylebox(&"disabled", themeID)
	_stylebox_focus = get_theme_stylebox(&"focus", themeID)

func _get_minimum_size() -> Vector2:
	if(_stylebox_normal):
		return (_stylebox_normal.get_minimum_size() + _font.get_string_size(_button_label, 0, -1, _font_size))
	else:
		return Vector2(2,2)
		pass
#endregion
