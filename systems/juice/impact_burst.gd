## One-shot particle burst that frees itself (Spec 010, G1).
## Jam-safe: pure CPUParticles2D, no material/shader setup. Build it in code,
## add it to the current scene, call burst(color) — it emits once and frees.
class_name ImpactBurst
extends CPUParticles2D


func _ready() -> void:
	emitting = false
	one_shot = true
	explosiveness = 1.0
	amount = 8
	lifetime = 0.45
	direction = Vector2.ZERO
	spread = 180.0
	initial_velocity_min = 60.0
	initial_velocity_max = 140.0
	gravity = Vector2.ZERO
	damping_min = 80.0
	damping_max = 140.0
	scale_amount_min = 2.0
	scale_amount_max = 4.0
	finished.connect(queue_free)


## Call after adding to the tree and positioning.
func burst(color: Color, count: int = 8) -> void:
	amount = count
	self.color = color
	emitting = true
