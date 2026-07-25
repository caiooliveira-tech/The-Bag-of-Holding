## Data half of a magic item (Spec 003). One .tres per catalog item.
class_name MagicItemResource
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
## Placeholder tint until real art lands (graybox policy).
@export var graybox_color: Color = Color.WHITE
@export var appearance: Texture2D
@export var activation_time_seconds: float = 3.0
@export var effect: MagicItemEffect
