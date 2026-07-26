## One beat of a cutscene (Spec 023). Data only — the player scene renders it.
## Authoring a new frame is an editor operation, never a code change.
class_name CutsceneFrameResource
extends Resource

## DIALOGUE: art above, parchment banner below with centered ink text (speech).
## READING_*: the prop fills one side, the written words sit on the other side
## with no banner — the player reading over Shoelace's shoulder.
enum Layout { DIALOGUE, READING_LEFT, READING_RIGHT }

@export_multiline var text: String = ""
## Optional: frames 1-2 of the intro show no art (the caw is off-screen).
@export var art: Texture2D
@export var layout: Layout = Layout.DIALOGUE
## Optional AudioManager SFX key played when the frame opens.
@export var sfx: StringName = &""
