@tool
extends MultiMeshInstance3D

@export var lod_switch: float = 10;
@export var multimesh_detailed: Resource;
@export var multimesh_simple: Resource;

func _process(_delta: float) -> void:
	# Object displacement
	if material_override.get_shader_parameter("enable_object_bending"):
		material_override.set_shader_parameter("object_position", $"../Sphere".position)

	# LOD
	var camera_pos

	if Engine.is_editor_hint():
		camera_pos = EditorInterface.get_editor_viewport_3d().get_camera_3d().global_position
	else:
		camera_pos = get_viewport().get_camera_3d().global_position

	var camera_distance = global_position.distance_to(camera_pos)

	if camera_distance < lod_switch:
		multimesh = multimesh_detailed
	else:
		multimesh = multimesh_simple
