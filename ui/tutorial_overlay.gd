## Tutorial overlay (autoload "TutorialOverlay", Spec 024). Listens for the
## floor's events, shows that floor's beats on parchment, and freezes play
## while one is open. Same shape as DeathScreen / Pause / LevelTitle: the
## room announces, the UI reacts — no room -> UI reference.
extends CanvasLayer

const PANEL_SIZE := Vector2(520, 210)

var _open: bool = false
## Beats already shown this run, so dying and retrying floor 1 doesn't lecture
## the player twice. Cleared by GameState.reset_run() through the run flag.
var _seen: Array[TutorialBeatResource] = []

var _root: Control
var _text: Label


func _ready() -> void:
	# Must keep processing input while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 90
	_build()
	EventBus.level_entered.connect(_on_level_entered)
	EventBus.room_cleared.connect(_on_room_cleared)


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.visible = false
	add_child(_root)

	# Bottom-right, like the mockup: it never covers the player or the doors.
	var pos := Vector2(MenuUI.SCREEN.x - PANEL_SIZE.x - 30.0,
			MenuUI.SCREEN.y - PANEL_SIZE.y - 60.0)
	MenuUI.panel(_root, MenuUI.BANNER, pos, PANEL_SIZE)

	_text = MenuUI.label("", MenuUI.FONT_SEMI, 17, MenuUI.INK)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text.position = pos + Vector2(56.0, 46.0)
	_text.size = Vector2(PANEL_SIZE.x - 112.0, 90.0)
	_root.add_child(_text)

	var hint := MenuUI.label("[SPACE] CLOSE", MenuUI.FONT_BOLD, 14, MenuUI.INK_MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = pos + Vector2(0.0, PANEL_SIZE.y - 62.0)
	hint.size.x = PANEL_SIZE.x
	_root.add_child(hint)


func _on_level_entered(_title: String) -> void:
	_show_beats(TutorialBeatResource.Trigger.LEVEL_START)


func _on_room_cleared() -> void:
	_show_beats(TutorialBeatResource.Trigger.LEVEL_CLEARED)


func _show_beats(trigger: TutorialBeatResource.Trigger) -> void:
	var level := RunManager.current_level()
	if level == null:
		return
	for beat in level.tutorial_beats:
		if beat.trigger == trigger and not (beat in _seen):
			_open_beat(beat)
			return


func _open_beat(beat: TutorialBeatResource) -> void:
	_seen.append(beat)
	_text.text = beat.text
	_open = true
	get_tree().paused = true
	_root.visible = true
	_root.modulate.a = 0.0
	create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) \
			.tween_property(_root, "modulate:a", 1.0, 0.2)


## SPACE only: a player mashing attack shouldn't dismiss a lesson unread, and
## ESC belongs to the pause menu.
func _input(event: InputEvent) -> void:
	if not _open:
		return
	if event is InputEventKey and event.pressed and not event.echo \
			and (event as InputEventKey).keycode == KEY_SPACE:
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	_open = false
	_root.visible = false
	get_tree().paused = false
	AudioManager.play_sfx(&"button_clicked")
