##A scrolling text label that tries to fit the width of it's parent control
##
##Make sure that control has both a height and width.
##This is supposed to be a drag and drop solution for relatively quick UI iteration using the default label rendering info
##otherwise like, I'd write a custom drawer here, but I don't wanna.
class_name SeamlessScrollingLabel

extends Label
@export var scroll_speed : float = -64
@export var spacer_text : String

var _current_scroll : float = 0
var _scroll_period : float = 200
var _check_string : String = ""

func _ready():
	if(text == "" || text.is_empty()):
		set_label("default implementation string")

func _notification(what: int) -> void:	
	match(what):
		NOTIFICATION_THEME_CHANGED:
			_update_dimensions()
		NOTIFICATION_RESIZED:
			_update_dimensions()

func set_label(v: String):
	_check_string = v + spacer_text
	_update_dimensions()

func _update_dimensions():	
	var _parent_width = (get_parent() as Control).size.x	
	var font_ref : Font
	var font_size : int = 0

	if(_check_string == ""):
		_check_string = text + spacer_text
	
	if(label_settings):
		font_ref = label_settings.font
		font_size = label_settings.font_size	
	else:		
		font_ref = get_theme_font("font")	
		font_size = get_theme_font_size("font_size")
	
	if not (font_ref):
		font_ref = get_theme_default_font()
	if not font_size:
		font_size = get_theme_default_font_size()
	
	_scroll_period = font_ref.get_string_size(_check_string, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

	var actual_text : String = ""	
	for x in ceili(_parent_width/_scroll_period)+2:
		actual_text += _check_string
	text = actual_text

func _process(delta):
	_current_scroll = wrapf(_current_scroll + (delta * scroll_speed), 0.0,_scroll_period)	
	set_position(Vector2(_current_scroll-_scroll_period, position.y), get_parent().size.y != 0)
