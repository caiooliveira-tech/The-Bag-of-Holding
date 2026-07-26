## A whole cutscene (Spec 023): an ordered list of frames plus where to go when
## it ends (or is skipped). One .tres per cutscene, so adding the ending scene
## later is pure data — no new code, same lesson as the magic-item framework.
class_name CutsceneResource
extends Resource

@export var frames: Array[CutsceneFrameResource] = []
@export_file("*.tscn") var next_scene_path: String = ""
