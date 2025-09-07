@tool
extends MultiMeshInstance3D

func _process(_delta: float) -> void:
	material_override.set_shader_parameter("object_position", $"../Sphere".position)
