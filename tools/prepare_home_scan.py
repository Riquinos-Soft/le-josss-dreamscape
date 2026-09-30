"""Prepare the supplied exterior in Blender, preserving its visible geometry.

blender --background --python tools/prepare_home_scan.py -- /path/to/source.glb
Only the texture is resized. A separate simplified mesh becomes static collision.
"""
import hashlib
import json
import sys
from pathlib import Path

import bpy

root = Path(__file__).resolve().parents[1]
source = Path(sys.argv[sys.argv.index('--') + 1]).expanduser().resolve()
output = root / 'game/assets/home_scan/exterior.glb'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(source))
meshes = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
assert len(meshes) == 1, 'Review unexpected multi-mesh input before preparing'
visual = meshes[0]
visual.name = 'CapturedExterior'
original_vertices = len(visual.data.vertices)
original_triangles = len(visual.data.polygons)
for image in bpy.data.images:
    if image.size[0] > 4096 or image.size[1] > 4096:
        factor = 4096 / max(image.size)
        image.scale(round(image.size[0] * factor), round(image.size[1] * factor))
for material in visual.data.materials:
    tree = material.node_tree
    texture = next(node.image for node in tree.nodes if node.type == 'TEX_IMAGE')
    tree.nodes.clear()
    tex = tree.nodes.new('ShaderNodeTexImage')
    tex.image = texture
    emission = tree.nodes.new('ShaderNodeEmission')
    surface = tree.nodes.new('ShaderNodeOutputMaterial')
    tree.links.new(tex.outputs['Color'], emission.inputs['Color'])
    tree.links.new(emission.outputs[0], surface.inputs['Surface'])
# A separate import-only collision surface; the visual mesh is never decimated.
collision = visual.copy()
collision.data = visual.data.copy()
bpy.context.collection.objects.link(collision)
collision.name = 'CapturedGround-colonly'
collision.data.materials.clear()
bpy.context.view_layer.objects.active = collision
modifier = collision.modifiers.new('CollisionSimplification', 'DECIMATE')
modifier.ratio = 0.20
bpy.ops.object.modifier_apply(modifier=modifier.name)
collision_triangles = len(collision.data.polygons)
output.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.export_scene.gltf(
    filepath=str(output), export_format='GLB', export_image_format='JPEG',
    export_image_quality=90, export_texcoords=True, export_normals=False,
    export_materials='EXPORT', export_yup=True,
)
report = {
    'source_file': source.name, 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
    'blender': bpy.app.version_string, 'visual_vertices': original_vertices,
    'visual_triangles': original_triangles, 'collision_triangles': collision_triangles,
    'texture_max_dimension': 4096, 'jpeg_quality': 90,
    'output_bytes': output.stat().st_size,
    'geometry_note': 'Original visual vertices, faces, UVs, transforms and scale retained; collision only decimated.',
}
(root / 'assets/source/home_scan/preparation.json').write_text(json.dumps(report, indent=2) + '\n')
print('PREPARATION_REPORT', json.dumps(report))
