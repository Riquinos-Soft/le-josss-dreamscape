const fs = require('node:fs');
const path = require('node:path');
const draco3d = require('draco3d');
const { MeshoptSimplifier } = require('meshoptimizer');

function decodeAttribute(draco, decoder, mesh, kind) {
  const attribute = decoder.GetAttributeByUniqueId(mesh, kind);
  if (!attribute || attribute.ptr === 0) throw new Error(`Missing Draco attribute ${kind}`);
  const values = new draco.DracoFloat32Array();
  if (!decoder.GetAttributeFloatForAllPoints(mesh, attribute, values)) {
    throw new Error(`Cannot decode Draco attribute ${kind}`);
  }
  const result = new Float32Array(values.size());
  for (let i = 0; i < result.length; i++) result[i] = values.GetValue(i);
  draco.destroy(values);
  return result;
}

async function decodeMesh(file) {
  const draco = await draco3d.createDecoderModule({});
  const source = new Int8Array(fs.readFileSync(file));
  const buffer = new draco.DecoderBuffer();
  buffer.Init(source, source.length);
  const decoder = new draco.Decoder();
  const mesh = new draco.Mesh();
  const status = decoder.DecodeBufferToMesh(buffer, mesh);
  if (!status.ok()) throw new Error(status.error_msg());

  const positions = decodeAttribute(draco, decoder, mesh, 0);
  const uvs = decodeAttribute(draco, decoder, mesh, 1);
  const indices = new Uint32Array(mesh.num_faces() * 3);
  const face = new draco.DracoInt32Array();
  for (let i = 0; i < mesh.num_faces(); i++) {
    decoder.GetFaceFromMesh(mesh, i, face);
    indices[i * 3] = face.GetValue(0);
    indices[i * 3 + 1] = face.GetValue(1);
    indices[i * 3 + 2] = face.GetValue(2);
  }
  draco.destroy(face);
  draco.destroy(mesh);
  draco.destroy(buffer);
  draco.destroy(decoder);
  return { positions, uvs, indices };
}

function compact(indices, positions, uvs) {
  const outIndices = new Uint32Array(indices);
  const [remap, vertexCount] = MeshoptSimplifier.compactMesh(outIndices);
  const outPositions = new Float32Array(vertexCount * 3);
  const outUvs = new Float32Array(vertexCount * 2);
  for (let old = 0; old < remap.length; old++) {
    const next = remap[old];
    if (next === 0xffffffff) continue;
    outPositions.set(positions.subarray(old * 3, old * 3 + 3), next * 3);
    outUvs.set(uvs.subarray(old * 2, old * 2 + 2), next * 2);
  }
  return { positions: outPositions, uvs: outUvs, indices: outIndices };
}

function normalsFor(positions, indices) {
  const normals = new Float32Array(positions.length);
  for (let i = 0; i < indices.length; i += 3) {
    const a = indices[i] * 3, b = indices[i + 1] * 3, c = indices[i + 2] * 3;
    const abx = positions[b] - positions[a], aby = positions[b + 1] - positions[a + 1], abz = positions[b + 2] - positions[a + 2];
    const acx = positions[c] - positions[a], acy = positions[c + 1] - positions[a + 1], acz = positions[c + 2] - positions[a + 2];
    const nx = aby * acz - abz * acy, ny = abz * acx - abx * acz, nz = abx * acy - aby * acx;
    for (const offset of [a, b, c]) {
      normals[offset] += nx;
      normals[offset + 1] += ny;
      normals[offset + 2] += nz;
    }
  }
  for (let i = 0; i < normals.length; i += 3) {
    const length = Math.hypot(normals[i], normals[i + 1], normals[i + 2]) || 1;
    normals[i] /= length;
    normals[i + 1] /= length;
    normals[i + 2] /= length;
  }
  return normals;
}

function bounds(positions) {
  const min = [Infinity, Infinity, Infinity], max = [-Infinity, -Infinity, -Infinity];
  for (let i = 0; i < positions.length; i += 3) {
    for (let axis = 0; axis < 3; axis++) {
      min[axis] = Math.min(min[axis], positions[i + axis]);
      max[axis] = Math.max(max[axis], positions[i + axis]);
    }
  }
  return { min, max };
}

function encodeGlb(mesh, output) {
  const normals = normalsFor(mesh.positions, mesh.indices);
  const blobs = [];
  const views = [];
  let binarySize = 0;
  function add(buffer, target) {
    const data = Buffer.isBuffer(buffer) ? buffer : Buffer.from(buffer.buffer, buffer.byteOffset, buffer.byteLength);
    const padding = (4 - binarySize % 4) % 4;
    if (padding) blobs.push(Buffer.alloc(padding));
    binarySize += padding;
    const view = { buffer: 0, byteOffset: binarySize, byteLength: data.length };
    if (target) view.target = target;
    const index = views.length;
    views.push(view);
    blobs.push(data);
    binarySize += data.length;
    return index;
  }
  const positionView = add(mesh.positions, 34962);
  const normalView = add(normals, 34962);
  const uvView = add(mesh.uvs, 34962);
  const indexView = add(mesh.indices, 34963);
  const positionBounds = bounds(mesh.positions);
  const gltf = {
    asset: { version: '2.0', generator: 'Dreamscape Scaniverse street trial' },
    scene: 0,
    scenes: [{ nodes: [0] }],
    nodes: [{ name: 'ScaniverseStreetVisual', mesh: 0 }],
    meshes: [{ primitives: [{ attributes: { POSITION: 0, NORMAL: 1, TEXCOORD_0: 2 }, indices: 3, material: 0 }] }],
    materials: [{ name: 'GeometryStudy', doubleSided: true, pbrMetallicRoughness: {
      baseColorFactor: [0.54, 0.62, 0.59, 1], metallicFactor: 0, roughnessFactor: 1,
    } }],
    buffers: [{ byteLength: binarySize }],
    bufferViews: views,
    accessors: [
      { bufferView: positionView, componentType: 5126, count: mesh.positions.length / 3, type: 'VEC3', ...positionBounds },
      { bufferView: normalView, componentType: 5126, count: normals.length / 3, type: 'VEC3' },
      { bufferView: uvView, componentType: 5126, count: mesh.uvs.length / 2, type: 'VEC2' },
      { bufferView: indexView, componentType: 5125, count: mesh.indices.length, type: 'SCALAR' },
    ],
  };
  const json = Buffer.from(JSON.stringify(gltf));
  const jsonPadding = (4 - json.length % 4) % 4;
  const bin = Buffer.concat([...blobs, Buffer.alloc((4 - binarySize % 4) % 4)]);
  const total = 12 + 8 + json.length + jsonPadding + 8 + bin.length;
  const header = Buffer.alloc(12);
  header.write('glTF', 0);
  header.writeUInt32LE(2, 4);
  header.writeUInt32LE(total, 8);
  const jsonHeader = Buffer.alloc(8);
  jsonHeader.writeUInt32LE(json.length + jsonPadding, 0);
  jsonHeader.write('JSON', 4);
  const binHeader = Buffer.alloc(8);
  binHeader.writeUInt32LE(bin.length, 0);
  binHeader.write('BIN\0', 4);
  fs.writeFileSync(output, Buffer.concat([header, jsonHeader, json, Buffer.alloc(jsonPadding, 0x20), binHeader, bin]));
  return positionBounds;
}

async function main() {
  const sourceDir = path.resolve(process.argv[2] || 'assets/work/scaniverse-2nt4wpvsrhi6zfza');
  const output = path.resolve(process.argv[3] || 'game/assets/streets/jacobo_risa/street.glb');
  const source = await decodeMesh(path.join(sourceDir, 'mesh.drc'));
  console.log(`decoded: ${source.positions.length / 3} vertices, ${source.indices.length / 3} triangles`);
  await MeshoptSimplifier.ready;
  MeshoptSimplifier.useExperimentalFeatures = true;
  const [simplified, error] = MeshoptSimplifier.simplifyWithAttributes(
    source.indices, source.positions, 3, source.uvs, 2, [0.1, 0.1], null,
    35000 * 3, 0.04, ['Prune', 'Permissive'],
  );
  console.log(`simplified: ${simplified.length / 3} triangles, relative error ${error}`);
  const mesh = compact(simplified, source.positions, source.uvs);
  fs.mkdirSync(path.dirname(output), { recursive: true });
  const resultBounds = encodeGlb(mesh, output);
  console.log(`GLB: ${output}, ${fs.statSync(output).size} bytes, ${mesh.positions.length / 3} vertices`);
  console.log('bounds', resultBounds);
}
main().catch(error => { console.error(error); process.exitCode = 1; });
