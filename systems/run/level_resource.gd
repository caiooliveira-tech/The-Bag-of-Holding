## One floor of the tower (Spec 016). Data only: the shared level scene reads
## this at _ready() and builds itself. Tuning or reordering the run is a .tres
## edit — twelve hand-built scenes would be a maintenance trap.
class_name LevelResource
extends Resource

## Announced by the drop-in sign (Spec 022).
@export var title: String = ""
## Palette row on the tile sheet: 0 = Act I, 1 = Act II, 2 = Act III.
@export_range(0, 2) var palette_row: int = 0

@export var chaser_count: int = 0
@export var shooter_count: int = 0

@export var wall_pattern: WallPatterns.Pattern = WallPatterns.Pattern.NONE

## Tutorial beats shown on this floor (Spec 024). Empty on every floor but 1.
@export var tutorial_beats: Array[TutorialBeatResource] = []
