## One tutorial message (Spec 024). Data only — adding a beat to any floor is
## a .tres edit plus one entry in that floor's LevelResource.
class_name TutorialBeatResource
extends Resource

## When the beat fires. LEVEL_START: on entering the floor.
## LEVEL_CLEARED: when its last enemy dies, as the doors open.
enum Trigger { LEVEL_START, LEVEL_CLEARED }

@export_multiline var text: String = ""
@export var trigger: Trigger = Trigger.LEVEL_START
