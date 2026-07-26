## The Magnetic Horseshoe's live blob (Spec 020 v2). Holds the glued members
## (enemies and/or the player) together for its lifetime by pulling each one
## toward the cluster's live centroid every physics frame. Members keep their
## own intent (AI / input), so the blob's net motion is the blend of its
## members — an enemies-only blob chases as one; a glued player drags it.
class_name MagnetCluster
extends Node2D

const SHEET: Texture2D = preload("res://entities/SHEETS_SHOELACE_INIMIGOS_ITENS_PROJETIL.png")
const ICON_REGION := Rect2(256, 96, 32, 32)

## Pull gain: velocity toward centroid per px of separation, and its cap.
## Strong enough to dominate walk speeds (~100-160) without teleporting.
const PULL_GAIN: float = 9.0
const PULL_MAX: float = 420.0

var _members: Array[Node2D] = []
var _time_left: float = 0.0


func setup(members: Array[Node2D], duration_seconds: float) -> void:
	_members = members
	_time_left = duration_seconds
	add_to_group("magnet_clusters")
	# The horseshoe icon rides the centroid so the hold reads on screen.
	var icon := Sprite2D.new()
	icon.texture = _icon_texture()
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(icon)
	var bob := create_tween().set_loops()
	bob.tween_property(icon, "position:y", -6.0, 0.35).set_trans(Tween.TRANS_SINE)
	bob.tween_property(icon, "position:y", 0.0, 0.35).set_trans(Tween.TRANS_SINE)


func _physics_process(delta: float) -> void:
	_time_left -= delta
	_members = _members.filter(func(m: Node2D) -> bool: return is_instance_valid(m))
	if _time_left <= 0.0 or _members.is_empty():
		_release()
		return
	var centroid := Vector2.ZERO
	for member in _members:
		centroid += member.global_position
	centroid /= _members.size()
	global_position = centroid
	for member in _members:
		var to_center := centroid - member.global_position
		var pull := (to_center * PULL_GAIN).limit_length(PULL_MAX)
		# Reusing the knockback channel moves both Player and Enemy without
		# touching their movement code; re-applied each frame = constant force.
		member.call(&"apply_knockback", pull)


func _release() -> void:
	# Stop the residual pull so members separate cleanly.
	for member in _members:
		if is_instance_valid(member):
			member.call(&"apply_knockback", Vector2.ZERO)
	queue_free()


func _icon_texture() -> Texture2D:
	var atlas := AtlasTexture.new()
	atlas.atlas = SHEET
	atlas.region = ICON_REGION
	return atlas
