## Cutscene player (Spec 023). Renders a CutsceneResource frame by frame:
## typewriter text, press to complete, press again to advance, ESC to skip.
## Presentation only — a standalone scene, so no gameplay is running behind it.
extends Control

## Assigned in the .tscn; swap it (or duplicate the scene) for another cutscene.
@export var cutscene: CutsceneResource

const REVEAL_CHARS_PER_SEC: float = 42.0
const FADE_SECONDS: float = 0.25

var _index: int = -1
var _revealing: bool = false
var _leaving: bool = false
var _reveal_tween: Tween

var _art: TextureRect
var _banner: TextureRect
var _text: Label
var _skip_hint: Label


func _ready() -> void:
	_build()
	if cutscene == null or cutscene.frames.is_empty():
		_leave()
		return
	_advance()


func _build() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color.BLACK
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	_art = TextureRect.new()
	_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_art)

	_banner = TextureRect.new()
	_banner.texture = MenuUI.BANNER
	_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_banner.stretch_mode = TextureRect.STRETCH_SCALE
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_banner)

	_text = MenuUI.label("", MenuUI.FONT_SEMI, 22, MenuUI.INK)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_text)

	# Top-right, over the black backdrop: the banner would swallow it at the
	# bottom, and light ink on parchment reads poorly.
	_skip_hint = MenuUI.label("[ESC] SKIP", MenuUI.FONT_REG, 14, MenuUI.LIGHT_MUTED)
	_skip_hint.position = Vector2(MenuUI.SCREEN.x - 110.0, 22.0)
	add_child(_skip_hint)


## Lay out the frame for its mode, then start the typewriter.
func _show_frame(frame: CutsceneFrameResource) -> void:
	_art.visible = frame.art != null
	_art.texture = frame.art
	var dialogue := frame.layout == CutsceneFrameResource.Layout.DIALOGUE
	_banner.visible = dialogue

	if dialogue:
		# Banner sits near the bottom with only a small bleed, and the art
		# perches on it, so the speaker and their words read as one unit
		# (Design's storyboard) while the text stays fully on-screen.
		var banner_size := Vector2(1180, 360)
		_banner.position = Vector2((MenuUI.SCREEN.x - banner_size.x) * 0.5,
				MenuUI.SCREEN.y - 322.0)
		_banner.size = banner_size
		_art.size = Vector2(600, 430)
		_art.position = Vector2((MenuUI.SCREEN.x - _art.size.x) * 0.5,
				_banner.position.y - _art.size.y + 44.0)
		_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_text.add_theme_color_override("font_color", MenuUI.INK)
		# Text in the visible upper half of the banner, tall enough for up to
		# ~4 lines so long speeches never run off the bottom of the screen.
		_text.position = Vector2(_banner.position.x + 120.0, _banner.position.y + 60.0)
		_text.size = Vector2(banner_size.x - 240.0, 210.0)
	else:
		# Reading: prop on one side, Euclidus's words in light text on the other.
		var art_left := frame.layout == CutsceneFrameResource.Layout.READING_LEFT
		var half := MenuUI.SCREEN.x * 0.5
		_art.size = Vector2(560, 560)
		_art.position = Vector2(40.0 if art_left else half + 60.0, 80.0)
		_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_text.add_theme_color_override("font_color", MenuUI.LIGHT)
		_text.position = Vector2(half + 60.0 if art_left else 80.0, 120.0)
		_text.size = Vector2(520, 480)

	if frame.sfx != &"":
		AudioManager.play_sfx(frame.sfx)
	_reveal(frame.text)


## Typewriter: reveal by character count so a press can complete it instantly.
func _reveal(text: String) -> void:
	_text.text = text
	_text.visible_characters = 0
	_revealing = true
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	var duration := float(text.length()) / REVEAL_CHARS_PER_SEC
	_reveal_tween = create_tween()
	_reveal_tween.tween_property(_text, "visible_characters", text.length(), duration)
	_reveal_tween.tween_callback(func() -> void: _revealing = false)


func _complete_reveal() -> void:
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_text.visible_characters = -1
	_revealing = false


func _advance() -> void:
	_index += 1
	if _index >= cutscene.frames.size():
		_leave()
		return
	var frame := cutscene.frames[_index]
	# Cross-fade between beats so art swaps read as a cut, not a pop.
	if _index == 0:
		_show_frame(frame)
		modulate.a = 0.0
		create_tween().tween_property(self, "modulate:a", 1.0, FADE_SECONDS * 2.0)
		return
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_SECONDS)
	tween.tween_callback(_show_frame.bind(frame))
	tween.tween_property(self, "modulate:a", 1.0, FADE_SECONDS)


func _leave() -> void:
	if _leaving:
		return
	_leaving = true
	# The intro has been watched (or skipped) — don't replay it this session.
	GameState.intro_seen = true
	var target := cutscene.next_scene_path if cutscene != null else ""
	if target.is_empty():
		return
	get_tree().change_scene_to_file.bind(target).call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if _leaving:
		return
	if event.is_action_pressed(&"ui_cancel"):
		AudioManager.play_sfx(&"button_clicked")
		_leave()
		return
	var pressed_key: bool = event is InputEventKey and event.pressed and not event.echo
	var pressed_pad: bool = event is InputEventJoypadButton and event.pressed
	var pressed_click: bool = event is InputEventMouseButton and event.pressed
	if not (pressed_key or pressed_pad or pressed_click):
		return
	# First press completes the line, the next one advances — never punishes
	# an eager reader by skipping a beat they haven't seen yet.
	if _revealing:
		_complete_reveal()
	else:
		_advance()
