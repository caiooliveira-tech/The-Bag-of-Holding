## Base class for all magic item effects (Spec 003).
## New effect types subclass this — the framework never needs a match/enum.
class_name MagicItemEffect
extends Resource


## Fires the effect at the item's position. Returns the affected targets.
## `item` is the MagicItem node (typed Node2D to keep Resources cycle-free).
func execute(_item: Node2D) -> Array[Node]:
	push_warning("MagicItemEffect.execute() not overridden")
	return []
