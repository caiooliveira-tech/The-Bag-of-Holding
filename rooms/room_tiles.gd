## Paints the room's floor and border at runtime from the shared sheet.
## Data-driven per Silas's tile template: `variant_row` picks the palette
## (0 = blue/row 1, 1 = pink/row 2). No hand-painted tile_data in scenes,
## so retiling a room is a property tweak, not a repaint.
## Collision stays on the room's StaticBody2D — these tiles are visual only.
extends TileMapLayer

const SOURCE_ID := 0
## Atlas columns (0-based) per the Design template (1-based cols 10/11).
const CORNER_TILE := Vector2i(9, 0)
const FLOOR_TILE := Vector2i(10, 0)

const FLIP_H := TileSetAtlasSource.TRANSFORM_FLIP_H
const FLIP_V := TileSetAtlasSource.TRANSFORM_FLIP_V

## 0 = row 1 palette (room 1), 1 = row 2 palette (room 2).
@export var variant_row: int = 0
## Room footprint; 12 rows cover the 360 px viewport (bottom border doubled).
@export var size_in_tiles: Vector2i = Vector2i(20, 12)
## Top-wall cells left open for the Door scene (floor shows through when open).
@export var door_gap_cells: Array[Vector2i] = [Vector2i(9, 0), Vector2i(10, 0)]


func _ready() -> void:
	var corner := CORNER_TILE + Vector2i(0, variant_row)
	var floor_tile := FLOOR_TILE + Vector2i(0, variant_row)
	for y in size_in_tiles.y:
		for x in size_in_tiles.x:
			var cell := Vector2i(x, y)
			if cell in door_gap_cells:
				set_cell(cell, SOURCE_ID, floor_tile)
				continue
			var is_border := x == 0 or x == size_in_tiles.x - 1 \
					or y == 0 or y >= size_in_tiles.y - 2
			if is_border:
				# The corner tile is authored top-left; mirror per quadrant
				# so the diagonal braces frame the room symmetrically.
				var alt := 0
				if x >= size_in_tiles.x / 2:
					alt |= FLIP_H
				if y >= size_in_tiles.y / 2:
					alt |= FLIP_V
				set_cell(cell, SOURCE_ID, corner, alt)
			else:
				set_cell(cell, SOURCE_ID, floor_tile)
