## Base class for all magic item effects (Spec 003).
## New effect types subclass this — the framework never needs a match/enum.
class_name MagicItemEffect
extends Resource


## Fires the effect at the item's position. Returns the affected targets.
## `item` is the MagicItem node (typed Node2D to keep Resources cycle-free).
func execute(_item: Node2D) -> Array[Node]:
	push_warning("MagicItemEffect.execute() not overridden")
	return []


## Stable identifier so feedback (camera, VFX) picks a profile without
## hardcoding item ids. Subclasses override; default is a neutral kind.
func effect_kind() -> StringName:
	return &"generic"


## Blast footprint in tiles, for the landing marker (Spec 010, G2). 0 = none.
func preview_radius_tiles() -> float:
	return 0.0
