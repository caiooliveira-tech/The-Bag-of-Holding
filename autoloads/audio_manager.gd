## Audio (autoload "AudioManager", Spec 013). Loops one background track and
## fires one-shot SFX off EventBus events. Files whose name contains
## "soundtrack" are background music; the rest are SFX named for their moment.
extends Node

const MUSIC := {
	&"menu": preload("res://assets/sounds/menu_soundtrack.mp3"),
	&"in_game": preload("res://assets/sounds/in_game_soundtrack.mp3"),
}

## Seconds to skip at the start of a track to cut a built-in fade-in. Applied
## both to the initial play and the loop point, so the intro never plays.
## Tune per track if the fade length differs.
const MUSIC_SKIP := {
	&"menu": 3.0,
}

const SFX := {
	&"button_change": preload("res://assets/sounds/button_change.mp3"),
	&"button_clicked": preload("res://assets/sounds/button_clicked.mp3"),
	&"draw_item": preload("res://assets/sounds/draw_item.mp3"),
	&"thrown_bomb": preload("res://assets/sounds/thrown_bomb.mp3"),
	&"dash": preload("res://assets/sounds/dash.mp3"),
	&"kick": preload("res://assets/sounds/kick.mp3"),
	&"player_hit": preload("res://assets/sounds/player_hit.mp3"),
	&"enemy_hit": preload("res://assets/sounds/enemy_hit.mp3"),
	&"door_open": preload("res://assets/sounds/door_open.mp3"),
	&"fireball_explosion": preload("res://assets/sounds/fireball_explosion.mp3"),
	&"freeze": preload("res://assets/sounds/freeze.mp3"),
	&"freeze_explosion": preload("res://assets/sounds/freeze-explosion.mp3"),
	&"hand_explosions": preload("res://assets/sounds/hand_explosions.mp3"),
	&"horse_explosion": preload("res://assets/sounds/horse_explosion.mp3"),
}

# Not const: we flip its `loop` flag in _ready (can't mutate a const member).
var _tick_stream: AudioStreamMP3 = preload("res://assets/sounds/clock_ticking.mp3")

## Explosion/trigger SFX per item. Right Hand plays the freeze cue on trigger;
## the un-freeze cue (freeze-explosion) fires later on freeze_ended.
const EXPLOSION_BY_ITEM := {
	&"fire_orb": &"fireball_explosion",
	&"right_hand_of_ursula": &"freeze",
	&"left_hand_of_ursula": &"hand_explosions",
	&"troy_wooden_horse": &"horse_explosion",
}

const SFX_VOICES := 10

var _music: AudioStreamPlayer
var _current_music: StringName = &""
var _sfx: Array[AudioStreamPlayer] = []
var _next_voice: int = 0
## Looping bomb-countdown tick, on while at least one item is counting down.
var _tick: AudioStreamPlayer
var _active_items: int = 0


func _ready() -> void:
	# Keep music and menu-click SFX alive while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music = AudioStreamPlayer.new()
	_music.bus = &"Master"
	_music.volume_db = -9.0
	add_child(_music)
	for stream in MUSIC.values():
		(stream as AudioStreamMP3).loop = true
	_tick_stream.loop = true
	_tick = AudioStreamPlayer.new()
	_tick.stream = _tick_stream
	_tick.volume_db = -6.0
	add_child(_tick)
	for i in SFX_VOICES:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sfx.append(player)

	EventBus.item_drawn.connect(_on_item_drawn)
	EventBus.item_thrown.connect(func(_i, _p, _dir): play_sfx(&"thrown_bomb"))
	EventBus.item_effect_triggered.connect(_on_item_effect)
	EventBus.player_damaged.connect(func(_a, _s): play_sfx(&"player_hit"))
	EventBus.enemy_damaged.connect(func(_e): play_sfx(&"enemy_hit"))
	EventBus.player_dashed.connect(func(): play_sfx(&"dash"))
	EventBus.player_kicked.connect(func(): play_sfx(&"kick"))
	EventBus.door_opened.connect(func(): play_sfx(&"door_open"))
	EventBus.freeze_ended.connect(func(): play_sfx(&"freeze_explosion"))


## Switch the looping background track. Also resets the countdown tick, so a
## room change (or return to menu) never leaves it stuck on.
func play_music(track: StringName) -> void:
	_reset_tick()
	if _current_music == track or not MUSIC.has(track):
		return
	_current_music = track
	var stream := MUSIC[track] as AudioStreamMP3
	var skip: float = MUSIC_SKIP.get(track, 0.0)
	stream.loop_offset = skip
	_music.stream = stream
	_music.play(skip)


func play_sfx(name: StringName) -> void:
	if not SFX.has(name):
		return
	var player := _sfx[_next_voice]
	_next_voice = (_next_voice + 1) % _sfx.size()
	player.stream = SFX[name]
	player.play()


func _on_item_drawn(_data: MagicItemResource) -> void:
	play_sfx(&"draw_item")
	_active_items += 1
	if not _tick.playing:
		_tick.play()


func _on_item_effect(item_id: StringName, _pos: Vector2, _kind: StringName) -> void:
	if EXPLOSION_BY_ITEM.has(item_id):
		play_sfx(EXPLOSION_BY_ITEM[item_id])
	_active_items = maxi(_active_items - 1, 0)
	if _active_items == 0:
		_tick.stop()


func _reset_tick() -> void:
	_active_items = 0
	if _tick != null:
		_tick.stop()
