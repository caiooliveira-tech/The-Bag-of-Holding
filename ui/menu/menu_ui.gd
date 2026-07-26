## Shared front-end art helper (Spec 022). Static builders + design tokens so
## every menu screen composes the same brick backdrop, parchment panels, logo,
## and ink-on-parchment text instead of duplicating the look five times.
## Pure presentation — no state, no gameplay.
class_name MenuUI
extends RefCounted

const FONT_BOLD: FontFile = preload("res://assets/fonts/Dellas-Bold.otf")
const FONT_SEMI: FontFile = preload("res://assets/fonts/Dellas-SemiBold.otf")
const FONT_REG: FontFile = preload("res://assets/fonts/Dellas-Regular.otf")

const BRICK: Texture2D = preload("res://assets/screens/3 - Options.jpg")
const SCROLL: Texture2D = preload("res://assets/screens/scroll.png")
const BANNER: Texture2D = preload("res://assets/screens/bg.png")
const SIGN: Texture2D = preload("res://assets/screens/bg2.png")
const CROW: Texture2D = preload("res://assets/screens/img-main-menu.png")
# Parchment pre-cropped to sit flush in the top-left corner (top + left edges
# straight, bottom + right torn/curled). Carries the logo on menu/pause.
const BG_LOGO: Texture2D = preload("res://assets/screens/bg-logo-main-menu.png")
# The bag on its own (transparent) — the item-acquired scroll's illustration.
const BAG: Texture2D = preload("res://assets/screens/bag.png")
const LOGO: Texture2D = preload("res://assets/logo-jogo.png")
const BTN_ACTIVE: Texture2D = preload("res://assets/ui/btn_active.png")
const BTN_INACTIVE: Texture2D = preload("res://assets/ui/btn_inactive.png")

# Text on parchment (dark ink) vs. text on the brick wall (light).
const INK: Color = Color(0.26, 0.17, 0.09)
const INK_MUTED: Color = Color(0.44, 0.33, 0.22)
const LIGHT: Color = Color(0.93, 0.90, 0.84)
const LIGHT_MUTED: Color = Color(0.64, 0.60, 0.55)

# Base design resolution; positions in the screens assume this canvas.
const SCREEN: Vector2 = Vector2(1280, 720)


## Full-screen dark brick wall backdrop. Added first so it sits behind all else.
static func brick(parent: Node) -> TextureRect:
	var bg := TextureRect.new()
	bg.texture = BRICK
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	return bg


## A parchment texture placed at pos, scaled to keep its aspect within size.
static func parchment(parent: Node, texture: Texture2D, pos: Vector2, size: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.position = pos
	rect.size = size
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


## A parchment panel that fills an exact rect (torn edges stretch to fit).
## Used where the panel size is fixed by layout, not by the texture's aspect.
static func panel(parent: Node, texture: Texture2D, pos: Vector2, size: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.position = pos
	rect.size = size
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


static func image(parent: Node, texture: Texture2D, pos: Vector2, size: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.position = pos
	rect.size = size
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


static func label(text: String, font: FontFile, size: int, color: Color) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_override("font", font)
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node


static func label_at(parent: Node, text: String, font: FontFile, size: int, color: Color, pos: Vector2) -> Label:
	var node := label(text, font, size, color)
	node.position = pos
	parent.add_child(node)
	return node


## A wooden button row (the shared btn_active/inactive art) carrying a caption.
## Returned so callers can swap its texture on selection via `select_button`.
static func button_row(parent: Node, caption: String, pos: Vector2) -> TextureRect:
	var row := TextureRect.new()
	row.texture = BTN_INACTIVE
	row.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	row.stretch_mode = TextureRect.STRETCH_SCALE
	row.position = pos
	row.custom_minimum_size = Vector2(320, 44)
	row.size = row.custom_minimum_size
	parent.add_child(row)
	var caption_label := label(caption, FONT_BOLD, 16, LIGHT)
	caption_label.position = Vector2(26, 11)
	row.add_child(caption_label)
	return row


## The logo on its corner parchment, glued flush to the top-left (no margins).
## The parchment aspect (561:350) is preserved by the matching rect so the torn
## edges don't distort. Shared by the main menu and the pause menu.
static func corner_logo(parent: Node) -> void:
	panel(parent, BG_LOGO, Vector2.ZERO, Vector2(384, 240))
	image(parent, LOGO, Vector2(28, 6), Vector2(300, 190))


## Toggle a button row between its active (wider) and inactive art.
static func select_button(row: TextureRect, active: bool) -> void:
	row.texture = BTN_ACTIVE if active else BTN_INACTIVE
	row.custom_minimum_size.x = 360.0 if active else 320.0
	row.size.x = row.custom_minimum_size.x
