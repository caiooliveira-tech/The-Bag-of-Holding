## Full-screen edge-vignette feedback (Spec 010, G1 + G5). EventBus-driven,
## presentation only — kept separate from the HUD so it never touches gameplay
## or the HUD layout. One white vignette, tinted per event: red on damage,
## gold on room clear.
extends CanvasLayer

@export var damage_color: Color = Color(0.85, 0.05, 0.05)
@export var damage_alpha: float = 0.55
@export var clear_color: Color = Color(1.0, 0.85, 0.35)
@export var clear_alpha: float = 0.4

var _vignette: TextureRect
var _tween: Tween


func _ready() -> void:
	layer = 10
	_vignette = TextureRect.new()
	_vignette.texture = _build_vignette()
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.modulate = Color(1, 1, 1, 0)
	add_child(_vignette)
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.room_cleared.connect(_on_room_cleared)


func _on_player_damaged(_amount: int, _source: Node) -> void:
	_flash(damage_color, damage_alpha, 0.28)


func _on_room_cleared() -> void:
	_flash(clear_color, clear_alpha, 0.6)


func _flash(color: Color, alpha: float, time: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_vignette.modulate = Color(color, alpha)
	_tween = create_tween()
	_tween.tween_property(_vignette, "modulate:a", 0.0, time)


## Radial gradient: transparent center → white at the edges. White so the
## flash colour comes entirely from modulate (one texture, many tints).
func _build_vignette() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	gradient.colors = PackedColorArray([
		Color(1, 1, 1, 0.0),
		Color(1, 1, 1, 0.0),
		Color(1, 1, 1, 1.0),
	])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 256
	tex.height = 256
	return tex
