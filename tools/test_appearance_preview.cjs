/* Compare the actual HTML pixel functions with Godot's composed frames. */
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const {colorizePixels, composePixels} = require('../backend/accounts/static/accounts/preview.js');
const folder = path.join(__dirname, '../build/verification/appearance-parity');
const catalog = require('../game/v2/characters/parts/palettes.json');
const manifest = JSON.parse(fs.readFileSync(path.join(folder, 'manifest.json')));
let checks = 0;
for (const [index, config] of manifest.cases.entries()) {
  const tinted = new Map();
  function texture(part, palette) {
    const key = part + ':' + palette;
    if (!tinted.has(key)) {
      const pixels = new Uint8ClampedArray(fs.readFileSync(path.join(folder, part + '.rgba')));
      tinted.set(key, colorizePixels(pixels, part, palette, catalog));
    }
    return tinted.get(key);
  }
  for (let row = 0; row < 8; row++) for (let column = 0; column < 5; column++) {
    const actual = composePixels(config, row, column, texture);
    const expected = fs.readFileSync(path.join(folder, `${index}-${row}-${column}.rgba`));
    assert.equal(Buffer.compare(Buffer.from(actual), expected), 0, `composition ${index}/${row}/${column}`);
    checks++;
  }
}
console.log(`HTML/Godot composition parity: ${checks} complete RGBA frames match`);
