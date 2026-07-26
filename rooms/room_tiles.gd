## Paints the room's floor and border at runtime from the shared sheet.
## Data-driven per Silas's tile template: `variant_row` picks the palette
## (0 = blue/row 1, 1 = pink/row 2). No hand-painted tile_data in scenes,
## so retiling a room is a property tweak, not a repaint.
## Collision stays on the room's StaticBody2D — these tiles are visual only.
extends TileMapLayer

const SOURCE_ID := 0
## Atlas coords (0-based) per the Design template (region x / 32):
## corner x288, wall x320, floor x352; doors live in the Door scene.
const CORNER_TILE := Vector2i(9, 0)
const WALL_TILE := Vector2i(10, 0)
const FLOOR_TILE := Vector2i(11, 0)

const FLIP_H := TileSetAtlasSource.TRANSFORM_FLIP_H
const FLIP_V := TileSetAtlasSource.TRANSFORM_FLIP_V
const TRANSPOSE := TileSetAtlasSource.TRANSFORM_TRANSPOSE
## The wall tile is authored as a TOP wall (inner face at the bottom edge);
## side walls rotate it so the inner face points into the room.
const ROTATE_CCW := TRANSPOSE | FLIP_V
const ROTATE_CW := TRANSPOSE | FLIP_H

## 0 = row 1 palette (room 1), 1 = row 2 palette (room 2).
@export var variant_row: int = 0
## Room footprint; 12 rows cover the 360 px viewport (bottom border doubled).
@export var size_in_tiles: Vector2i = Vector2i(20, 12)
## Wall cells left open for the Door scenes (floor shows through when open):
## one gap on the top wall, one on each side wall.
@export var door_gap_cells: Array[Vector2i] = [
	Vector2i(10, 0), Vector2i(0, 5), Vector2i(19, 5),
]


func _ready() -> void:
	repaint()


## Public so a level can set `variant_row` and repaint: child _ready() runs
## before the parent's, so the palette would otherwise be a frame too late.
func repaint() -> void:
	var corner := CORNER_TILE + Vector2i(0, variant_row)
	var wall := WALL_TILE + Vector2i(0, variant_row)
	var floor_tile := FLOOR_TILE + Vector2i(0, variant_row)
	for y in size_in_tiles.y:
		for x in size_in_tiles.x:
			var cell := Vector2i(x, y)
			if cell in door_gap_cells:
				set_cell(cell, SOURCE_ID, floor_tile)
				continue
			var is_top := y == 0
			var is_bottom := y >= size_in_tiles.y - 2
			var is_left := x == 0
			var is_right := x == size_in_tiles.x - 1
			if (is_left or is_right) and (is_top or is_bottom):
				# Corner tile is authored top-left; mirror toward its corner.
				var alt := 0
				if is_right:
					alt |= FLIP_H
				if is_bottom:
					alt |= FLIP_V
				set_cell(cell, SOURCE_ID, corner, alt)
			elif is_top or is_bottom or is_left or is_right:
				var alt := 0
				if is_bottom:
					alt = FLIP_V
				elif is_left:
					alt = ROTATE_CCW
				elif is_right:
					alt = ROTATE_CW
				set_cell(cell, SOURCE_ID, wall, alt)
			else:
				set_cell(cell, SOURCE_ID, floor_tile)
