## Title screen (Spec 022). Shown right after the blank black boot splash:
## the logo on a centered scroll with a blinking "press any button" prompt.
## Any key or joypad button advances to the main menu. Menu music starts here
## (AudioManager holds it on web until this first interaction).
extends Control

const MAIN_MENU := "res://ui/menu/main_menu.tscn"

var _prompt: Label
var _advancing: bool = false


func _ready() -> void:
	AudioManager.play_music(&"menu")
	_build()
	# Fade the whole screen in, so it reads as "arriving" after the black splash.
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.6)
	_blink()


func _build() -> void:
	MenuUI.brick(self)

	var scroll_size := Vector2(600, 600)
	var scroll_pos := (MenuUI.SCREEN - scroll_size) * 0.5
	MenuUI.parchment(self, MenuUI.SCROLL, scroll_pos, scroll_size)

	# Logo sits in the upper half of the scroll.
	var logo_size := Vector2(360, 280)
	var logo_pos := Vector2((MenuUI.SCREEN.x - logo_size.x) * 0.5, scroll_pos.y + 120.0)
	MenuUI.image(self, MenuUI.LOGO, logo_pos, logo_size)

	_prompt = MenuUI.label("PRESS ANY BUTTON TO START", MenuUI.FONT_SEMI, 20, MenuUI.INK)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.size.x = MenuUI.SCREEN.x
	_prompt.position = Vector2(0, scroll_pos.y + scroll_size.y - 170.0)
	add_child(_prompt)


## Soft pulse on the prompt so it draws the eye without flashing harshly.
func _blink() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_prompt, "modulate:a", 0.15, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_prompt, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if _advancing:
		return
	var pressed_key: bool = event is InputEventKey and event.pressed and not event.echo
	var pressed_pad: bool = event is InputEventJoypadButton and event.pressed
	var pressed_click: bool = event is InputEventMouseButton and event.pressed
	if pressed_key or pressed_pad or pressed_click:
		_advancing = true
		AudioManager.play_sfx(&"button_clicked")
		get_tree().change_scene_to_file(MAIN_MENU)
