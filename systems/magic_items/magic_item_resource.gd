## Data half of a magic item (Spec 003). One .tres per catalog item.
class_name MagicItemResource
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
## Placeholder tint until real art lands (graybox policy).
@export var graybox_color: Color = Color.WHITE
@export var appearance: Texture2D
@export var activation_time_seconds: float = 3.0
## Null for items whose danger isn't an end-of-countdown area effect (Troy,
## Spec 012 — its damage is the contact charge; it just despawns on timeout).
@export var effect: MagicItemEffect
## Troy (Spec 012): thrown item charges in an L instead of the 2-tile hop.
@export var charge_on_throw: bool = false
