"""Offline authoring: decode Scaniverse Draco mesh and texture into a Godot GLB.

Usage: python tools/prepare_lourizan_scan.py mesh.drc tex.jpg
Requires DracoPy, trimesh, numpy, Pillow, and fast-simplification (authoring only).
"""
import hashlib
import io
import json
import struct
import sys
from pathlib import Path

import DracoPy
import numpy as np
import trimesh
from PIL import Image

root = Path(__file__).resolve().parents[1]
source_mesh = Path(sys.argv[1]).resolve()
source_texture = Path(sys.argv[2]).resolve()
output = root / 'game/assets/lourizan/exterior.glb'
mesh = DracoPy.decode(source_mesh.read_bytes())
assert mesh.faces.shape[0] == 264177, 'Unexpected source: review before exporting'
assert mesh.tex_coord.shape[0] == mesh.points.shape[0], 'Texture coordinates missing'
image = Image.open(source_texture).convert('RGB')
if max(image.size) > 4096:
    image.thumbnail((4096, 4096), Image.Resampling.LANCZOS)
visual_mesh = trimesh.Trimesh(vertices=mesh.points, faces=mesh.faces, process=False)
visual_mesh.visual = trimesh.visual.TextureVisuals(
    uv=np.column_stack((mesh.tex_coord[:, 0], 1.0 - mesh.tex_coord[:, 1])),
    material=trimesh.visual.material.SimpleMaterial(image=image, name='LourizanCapture'),
)
collision_mesh = trimesh.Trimesh(vertices=mesh.points, faces=mesh.faces, process=False)
collision_mesh = collision_mesh.simplify_quadric_decimation(face_count=55000)
scene = trimesh.Scene()
scene.add_geometry(visual_mesh, node_name='CapturedExterior', geom_name='CapturedExterior')
scene.add_geometry(collision_mesh, node_name='CapturedGround-colonly', geom_name='CapturedGround-colonly')
output.parent.mkdir(parents=True, exist_ok=True)
glb = scene.export(file_type='glb', include_normals=False)
# Trimesh embeds RGB images as PNG. Keep the photographic Web payload compact.
json_length = struct.unpack_from('<I', glb, 12)[0]
layout = json.loads(glb[20:20 + json_length])
binary_start = 20 + json_length + 8
view_index = layout['images'][0]['bufferView']
view = layout['bufferViews'][view_index]
start = view['byteOffset']
end = start + view['byteLength']
image_bytes = io.BytesIO()
image.save(image_bytes, format='JPEG', quality=90)
jpeg = image_bytes.getvalue()
padding = (-len(jpeg)) % 4
replacement = jpeg + b'\x00' * padding
binary = glb[binary_start:]
binary = binary[:start] + replacement + binary[end:]
delta = len(replacement) - (end - start)
view['byteLength'] = len(jpeg)
for other in layout['bufferViews']:
    if other['byteOffset'] >= end:
        other['byteOffset'] += delta
layout['images'][0]['mimeType'] = 'image/jpeg'
layout['buffers'][0]['byteLength'] = len(binary)
encoded = json.dumps(layout, separators=(',', ':')).encode('utf-8')
encoded += b' ' * ((-len(encoded)) % 4)
output.write_bytes(
    struct.pack('<III', 0x46546c67, 2, 12 + 8 + len(encoded) + 8 + len(binary))
    + struct.pack('<II', len(encoded), 0x4e4f534a) + encoded
    + struct.pack('<II', len(binary), 0x004e4942) + binary
)
report = {
    'source_mesh_sha256': hashlib.sha256(source_mesh.read_bytes()).hexdigest(),
    'source_texture_sha256': hashlib.sha256(source_texture.read_bytes()).hexdigest(),
    'visual_vertices': int(len(mesh.points)),
    'visual_triangles': int(len(mesh.faces)),
    'collision_triangles': int(len(collision_mesh.faces)),
    'bounds_min': mesh.points.min(axis=0).tolist(),
    'bounds_max': mesh.points.max(axis=0).tolist(),
    'texture_dimension': list(image.size),
    'output_bytes': output.stat().st_size,
    'note': 'Source point positions and faces retained; UV V coordinate converted to glTF convention; texture and collision simplified.',
}
(root / 'assets/source/lourizan/preparation.json').write_text(json.dumps(report, indent=2) + '\n')
print('PREPARATION_REPORT', json.dumps(report))
