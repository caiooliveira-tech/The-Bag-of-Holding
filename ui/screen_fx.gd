## Full-screen damage feedback (Spec 010, G1). A red edge vignette that
## flashes when the player is hit. EventBus-driven, presentation only — kept
## separate from the HUD so it never touches gameplay or the HUD layout.
extends CanvasLayer

@export var flash_color: Color = Color(0.85, 0.05, 0.05)
@export var flash_alpha: float = 0.55
@export var flash_time: float = 0.28

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


func _on_player_damaged(_amount: int, _source: Node) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_vignette.modulate.a = flash_alpha
	_tween = create_tween()
	_tween.tween_property(_vignette, "modulate:a", 0.0, flash_time)


## Radial gradient: transparent center → red at the screen edges. Built in
## code so there's no asset to ship and the colour stays tunable.
func _build_vignette() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	gradient.colors = PackedColorArray([
		Color(flash_color, 0.0),
		Color(flash_color, 0.0),
		Color(flash_color, 1.0),
	])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 256
	tex.height = 256
	return tex
