## The shared floor (Spec 016). One scene builds every level: it asks
## RunManager which LevelResource is current, then paints its palette, stamps
## its maze and spawns its enemies before handing over to Room's state machine.
extends Room

const CHASER: PackedScene = preload("res://entities/enemies/enemy1.tscn")
const SHOOTER: PackedScene = preload("res://entities/enemies/enemy2.tscn")
const SHEET: Texture2D = preload("res://entities/SHEETS_SHOELACE_INIMIGOS_ITENS_PROJETIL.png")

## The same two sprites cycle through the acts recoloured and buffed (Spec
## 016): each act's stats variant is tougher and wears its own tint, so a
## veteran enemy is readable at a glance without new art.
const CHASER_TIERS: Array[EnemyStats] = [
	preload("res://entities/enemies/melee_grunt.tres"),
	preload("res://entities/enemies/melee_grunt_ii.tres"),
	preload("res://entities/enemies/melee_grunt_iii.tres"),
]
const SHOOTER_TIERS: Array[EnemyStats] = [
	preload("res://entities/enemies/ranged_shooter.tres"),
	preload("res://entities/enemies/ranged_shooter_ii.tres"),
	preload("res://entities/enemies/ranged_shooter_iii.tres"),
]

## Door art columns on the sheet (x px); the row is the level's palette.
const DOOR_CLOSED_X := 224
const DOOR_OPEN_X := 256

## Spawn candidates in tile coords, ordered so early enemies stand apart and
## later ones fill in. Cells taken by the maze are skipped.
const SPAWN_CELLS: Array[Vector2i] = [
	Vector2i(4, 3), Vector2i(15, 3), Vector2i(9, 2), Vector2i(4, 7),
	Vector2i(15, 7), Vector2i(2, 5), Vector2i(17, 5), Vector2i(12, 8),
	Vector2i(7, 8), Vector2i(12, 2),
]
## Never spawn an enemy on top of the player's start.
const PLAYER_CELL := Vector2i(10, 9)

var level: LevelResource

@onready var _room_tiles: TileMapLayer = $RoomTiles
@onready var _wall_tiles: TileMapLayer = $WallTiles


func _ready() -> void:
	level = RunManager.current_level()
	level_title = level.title
	next_scene_path = RunManager.next_scene_path()
	_apply_palette()
	var blocked := WallPatterns.stamp(_wall_tiles, level.wall_pattern, level.palette_row)
	_spawn_enemies(blocked)
	# Room counts enemies and wires doors — everything above must exist first.
	super._ready()


func _apply_palette() -> void:
	_room_tiles.set("variant_row", level.palette_row)
	_room_tiles.call("repaint")
	var closed := _door_texture(DOOR_CLOSED_X)
	var open := _door_texture(DOOR_OPEN_X)
	for node in $Doors.get_children():
		node.set("closed_texture", closed)
		node.set("open_texture", open)


func _door_texture(x: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = SHEET
	atlas.region = Rect2(x, 32 * level.palette_row, 32, 32)
	return atlas


## PEN is the one pattern that wants its enemy *inside* the walls (Spec 024's
## risk-free tutorial); every other pattern spawns around the maze.
func _spawn_enemies(blocked: Array[Vector2i]) -> void:
	var tier: int = clampi(level.palette_row, 0, CHASER_TIERS.size() - 1)
	if level.wall_pattern == WallPatterns.Pattern.PEN:
		_spawn(CHASER, CHASER_TIERS[tier], Vector2i(9, 4))
		return
	var cells := SPAWN_CELLS.filter(func(c: Vector2i) -> bool:
			return not (c in blocked) and c != PLAYER_CELL)
	var index := 0
	for i in level.chaser_count:
		if index < cells.size():
			_spawn(CHASER, CHASER_TIERS[tier], cells[index])
			index += 1
	for i in level.shooter_count:
		if index < cells.size():
			_spawn(SHOOTER, SHOOTER_TIERS[tier], cells[index])
			index += 1


func _spawn(scene: PackedScene, stats: EnemyStats, cell: Vector2i) -> void:
	var enemy := scene.instantiate() as Node2D
	enemy.set("stats", stats)
	enemy.position = Vector2(cell) * GameState.TILE_SIZE + Vector2(16, 16)
	add_child(enemy)
