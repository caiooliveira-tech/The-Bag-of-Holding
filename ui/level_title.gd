## Level Title overlay (autoload "LevelTitle", Spec 022). Mirrors the
## DeathScreen / Pause autoload pattern: a CanvasLayer that reacts to an
## EventBus signal. When a room announces `level_entered(title)`, a hanging
## sign drops from the top center, holds, then lifts out. Non-blocking:
## mouse input passes through and it never pauses the game.
extends CanvasLayer

const SIGN: Texture2D = preload("res://assets/screens/bg2.png")
const FONT_BOLD: FontFile = preload("res://assets/fonts/Dellas-Bold.otf")
const INK: Color = Color(0.26, 0.17, 0.09)

const SIGN_SIZE: Vector2 = Vector2(460, 174)
const HELD_Y: float = 12.0        # resting Y once dropped in
const HOLD_SECONDS: float = 1.4
const OVERLAY_ALPHA: float = 0.55  # black dim behind the sign while it shows

var _sign: Control
var _label: Label
var _overlay: ColorRect
var _hidden_y: float


func _ready() -> void:
	layer = 15
	# Sits above gameplay but below the pause menu (layer 20) and death screen.
	_build()
	EventBus.level_entered.connect(_on_level_entered)


func _build() -> void:
	# Black dim behind the sign, so the announcement reads over the room.
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

	_sign = Control.new()
	_sign.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sign.size = SIGN_SIZE
	_sign.position.x = (1280.0 - SIGN_SIZE.x) * 0.5
	_hidden_y = -SIGN_SIZE.y - 20.0
	_sign.position.y = _hidden_y
	add_child(_sign)

	var tex := TextureRect.new()
	tex.texture = SIGN
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	tex.size = SIGN_SIZE
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sign.add_child(tex)

	_label = Label.new()
	_label.add_theme_font_override("font", FONT_BOLD)
	_label.add_theme_font_size_override("font_size", 26)
	_label.add_theme_color_override("font_color", INK)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size = Vector2(SIGN_SIZE.x, 120)
	_label.position = Vector2(0, 28)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sign.add_child(_label)


func _on_level_entered(title: String) -> void:
	if title.is_empty():
		return
	_label.text = title
	# Dim fades in with the drop and out with the lift, in step with the sign.
	var dim := create_tween()
	dim.tween_property(_overlay, "color:a", OVERLAY_ALPHA, 0.5)
	dim.tween_interval(HOLD_SECONDS)
	dim.tween_property(_overlay, "color:a", 0.0, 0.4)

	var tween := create_tween()
	tween.tween_property(_sign, "position:y", HELD_Y, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(HOLD_SECONDS)
	tween.tween_property(_sign, "position:y", _hidden_y, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
