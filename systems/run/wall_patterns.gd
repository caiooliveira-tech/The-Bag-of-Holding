## Maze generator (Spec 016). Stamps a named pattern into a level's WallTiles
## layer instead of hand-painting twelve scenes. The wall tiles carry their own
## collision and block line of sight (Phase 6A), so cover is automatic.
##
## Two rules every pattern obeys:
##   1. never occupy the cell in front of a door (the run would dead-end);
##   2. never seal a spawn — PEN is the deliberate exception, it pens the
##      tutorial enemy so the player can practise safely.
class_name WallPatterns
extends RefCounted

enum Pattern { NONE, PEN, CROSS, TIC_TAC_TOE, RING }

const SOURCE_ID := 0
## Interior wall tiles live on sheet cols 0-5, rows 5-7 (one row per palette);
## col 5 is the solid "center" block used for barriers.
const BLOCK_COL := 5
const FIRST_WALL_ROW := 5

## Room interior in tile coords (border is row/col 0, bottom border is 2 rows).
const INTERIOR_MIN := Vector2i(1, 1)
const INTERIOR_MAX := Vector2i(18, 9)
## Cells that must stay walkable: in front of the top, left and right doors.
const DOOR_APPROACH: Array[Vector2i] = [
	Vector2i(10, 1), Vector2i(1, 5), Vector2i(18, 5),
]


## Paints `pattern` and returns the occupied cells so the caller can keep
## spawns off them.
static func stamp(layer: TileMapLayer, pattern: Pattern, palette_row: int) -> Array[Vector2i]:
	var cells := _cells_for(pattern)
	var tile := Vector2i(BLOCK_COL, FIRST_WALL_ROW + palette_row)
	var painted: Array[Vector2i] = []
	for cell in cells:
		if cell in DOOR_APPROACH:
			continue  # rule 1, enforced here so no pattern can violate it
		if cell.x < INTERIOR_MIN.x or cell.x > INTERIOR_MAX.x \
				or cell.y < INTERIOR_MIN.y or cell.y > INTERIOR_MAX.y:
			continue
		layer.set_cell(cell, SOURCE_ID, tile)
		painted.append(cell)
	return painted


static func _cells_for(pattern: Pattern) -> Array[Vector2i]:
	match pattern:
		Pattern.PEN:
			return _pen()
		Pattern.CROSS:
			return _cross()
		Pattern.TIC_TAC_TOE:
			return _tic_tac_toe()
		Pattern.RING:
			return _ring()
		_:
			return []


## A closed 4x3 enclosure mid-room. The tutorial enemy spawns inside it and
## can never reach the player; a thrown item still lands over the wall.
static func _pen() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x in range(8, 12):
		cells.append(Vector2i(x, 3))
		cells.append(Vector2i(x, 6))
	for y in range(3, 7):
		cells.append(Vector2i(8, y))
		cells.append(Vector2i(11, y))
	return cells


## Plus-shaped centre barrier: four clean approach lanes, easy to read.
static func _cross() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(2, 9):
		cells.append(Vector2i(9, y))
		cells.append(Vector2i(10, y))
	for x in range(5, 15):
		cells.append(Vector2i(x, 5))
	return cells


## `#` grid with deliberate gaps in every bar — nine pockets, many blind
## corners, but no sealed cell (the gaps are what keep it fair).
static func _tic_tac_toe() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(2, 9):
		if y == 5:
			continue  # gap so the verticals never seal a pocket
		cells.append(Vector2i(6, y))
		cells.append(Vector2i(13, y))
	for x in range(3, 17):
		if x in [9, 10]:
			continue  # gap on the horizontals
		cells.append(Vector2i(x, 3))
		cells.append(Vector2i(x, 7))
	return cells


## Broken rectangle ring with a gap mid-side: circular play that gives a
## kiting shooter somewhere to orbit and the player somewhere to cut across.
static func _ring() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x in range(5, 15):
		if x in [9, 10]:
			continue
		cells.append(Vector2i(x, 2))
		cells.append(Vector2i(x, 8))
	for y in range(2, 9):
		if y == 5:
			continue
		cells.append(Vector2i(5, y))
		cells.append(Vector2i(14, y))
	return cells
